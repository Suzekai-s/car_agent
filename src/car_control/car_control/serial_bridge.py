#!/usr/bin/env python3
"""serial_bridge: 上位机 ↔ STM32 串口双向通信桥接 + 里程计.

发送:
  V <linear> <angular>\n   速度指令
  H <timestamp_ms>\n        心跳包 (500ms)

接收:
  E <left_ticks> <right_ticks>\n   编码器累计脉冲 (50Hz)

里程计参数通过ROS2参数配置:
  wheel_diameter      轮径 (m)
  track_width         履带中心距 (m)
  ticks_per_rev       编码器每转脉冲数
  gear_ratio          减速比
  encoder_multiplier  编码器倍频 (正交解码)
"""

import math
import threading
import rclpy
from rclpy.node import Node
from geometry_msgs.msg import Twist, TransformStamped
from nav_msgs.msg import Odometry
from tf2_ros import TransformBroadcaster
import serial
import serial.tools.list_ports
import time


class SerialBridge(Node):
    def __init__(self):
        super().__init__("serial_bridge")
        self.declare_parameter("port", "auto")
        self.declare_parameter("baudrate", 115200)
        self.declare_parameter("heartbeat_interval", 0.5)
        self.declare_parameter("wheel_diameter", 0.043)
        self.declare_parameter("track_width", 0.235)
        self.declare_parameter("ticks_per_rev", 500)
        self.declare_parameter("gear_ratio", 30.0)
        self.declare_parameter("encoder_multiplier", 4.0)

        self._x = self._y = self._theta = 0.0
        self._last_left = self._last_right = None
        self._last_odom_time = None

        self._serial = None
        self._connect_serial()

        self._tf_broadcaster = TransformBroadcaster(self)
        self._odom_pub = self.create_publisher(Odometry, "/odom", 50)

        if self._serial:
            self._read_thread = threading.Thread(target=self._read_loop, daemon=True)
            self._read_thread.start()

        hb = self._get_param("heartbeat_interval").value
        self._hb_timer = self.create_timer(hb, self._send_heartbeat)
        self._last_cmd_time = time.time()
        self._sub = self.create_subscription(Twist, "/car/cmd_vel", self._cmd_callback, 10)

        self.get_logger().info("✅ serial_bridge 已启动")

    def _get_param(self, name):
        return self.get_parameter(name)

    def _connect_serial(self):
        port_config = self._get_param("port").value
        if port_config in ("none", "disable", ""):
            self.get_logger().info("串口已禁用")
            return
        if port_config == "auto":
            ports = serial.tools.list_ports.comports()
            self.get_logger().info(f"检测到 {len(ports)} 个串口设备:")

            # — 已知会被其他节点占用的串口设备（自动检测时跳过） —
            # LiDAR 驱动通过 lsn10p.yaml 配置为 /dev/ttyACM0
            lidar_patterns = ["lslidar", "lsiosr", "lsm10", "n10", "m10", "lsx10"]
            # LiDAR 驱动配置为 serial_port_: /dev/ttyACM0，自动检测时避开
            lidar_ports = ["/dev/ttyACM0"]

            stm_candidates = []   # 优先：像 STM32 的
            other_candidates = []  # 兜底：其他 USB 串口

            for p in ports:
                desc = (p.description + " " + p.hwid + " " + p.device).lower()
                self.get_logger().info(f"  {p.device}: {p.description}")

                # 跳过 LiDAR 占用的口
                if any(kw in desc for kw in lidar_patterns):
                    self.get_logger().info(f"    ↳ 跳过（疑似 LiDAR）")
                    continue
                if p.device in lidar_ports:
                    self.get_logger().info(f"    ↳ 跳过（该端口被 LiDAR 占用）")
                    continue

                if any(kw in desc for kw in ["stm", "stlink"]):
                    stm_candidates.append(p.device)
                elif any(kw in desc for kw in ["ch340", "ch910", "cp210", "silicon", "uart"]):
                    other_candidates.append(p.device)
                elif "usb" in desc and "serial" in desc:
                    other_candidates.append(p.device)

            candidates = stm_candidates + other_candidates

            if not candidates:
                self.get_logger().error(
                    "未找到 STM32 串口。可手动指定 serial_bridge.port:=/dev/ttyUSB0"
                    "，或先确认 STM32 已连接")
                return
            port = candidates[0]
            self.get_logger().info(f"自动选择串口: {port}")
        else:
            port = port_config
        try:
            self._serial = serial.Serial(
                port=port,
                baudrate=self._get_param("baudrate").value,
                timeout=0.1,
                write_timeout=0.1,
            )
            self.get_logger().info(f"✅ 串口已连接: {port}")
        except serial.SerialException as e:
            self.get_logger().error(f"❌ 串口打开失败 {port}: {e}")

    def _send_line(self, line: str):
        if self._serial and self._serial.is_open:
            try:
                data = (line + "\n").encode("utf-8")
                n = self._serial.write(data)
                self.get_logger().info(f"→ TX: {line} (bytes={n})")
            except serial.SerialException as e:
                self.get_logger().error(f"❌ 串口写入失败: {e}")

    def _cmd_callback(self, msg: Twist):
        self._last_cmd_time = time.time()
        self._send_line(f"V {msg.linear.x:.2f} {msg.angular.z:.2f}")

    def _send_heartbeat(self):
        if time.time() - self._last_cmd_time > 2.0:
            self._send_line("V 0.00 0.00")
        self._send_line(f"H {int(time.time() * 1000)}")

    def _read_loop(self):
        buf = ""
        while rclpy.ok() and self._serial and self._serial.is_open:
            try:
                if self._serial.in_waiting > 0:
                    data = self._serial.read(self._serial.in_waiting).decode("utf-8", errors="ignore")
                    buf += data
                    while "\n" in buf:
                        line, buf = buf.split("\n", 1)
                        line = line.strip()
                        if line:
                            self._parse_line(line)
                else:
                    time.sleep(0.005)
            except serial.SerialException:
                break

    def _parse_line(self, line: str):
        self.get_logger().info(f"← RX: {line}")
        parts = line.split()
        if parts and parts[0] == "E" and len(parts) >= 3:
            try:
                self._update_odom(int(parts[1]), int(parts[2]))
            except ValueError:
                pass

    def _update_odom(self, left_ticks: int, right_ticks: int):
        now = self.get_clock().now()
        wheel_d = self._get_param("wheel_diameter").value
        track = self._get_param("track_width").value
        tpr = self._get_param("ticks_per_rev").value
        gear = self._get_param("gear_ratio").value
        em = self._get_param("encoder_multiplier").value
        dist_per_tick = math.pi * wheel_d / (tpr * gear * em)

        if self._last_left is None:
            self._last_left = left_ticks
            self._last_right = right_ticks
            self._last_odom_time = now
            return

        delta_l = (left_ticks - self._last_left) * dist_per_tick
        delta_r = (right_ticks - self._last_right) * dist_per_tick
        self._last_left = left_ticks
        self._last_right = right_ticks

        delta_s = (delta_l + delta_r) / 2.0
        delta_theta = (delta_r - delta_l) / track
        self._theta += delta_theta
        self._x += delta_s * math.cos(self._theta)
        self._y += delta_s * math.sin(self._theta)

        dt = (now - self._last_odom_time).nanoseconds / 1e9
        self._last_odom_time = now
        vx = delta_s / dt if dt > 0 else 0.0
        vth = delta_theta / dt if dt > 0 else 0.0

        odom = Odometry()
        odom.header.stamp = now.to_msg()
        odom.header.frame_id = "odom"
        odom.child_frame_id = "base_link"
        odom.pose.pose.position.x = self._x
        odom.pose.pose.position.y = self._y
        odom.pose.pose.orientation.z = math.sin(self._theta / 2.0)
        odom.pose.pose.orientation.w = math.cos(self._theta / 2.0)
        odom.twist.twist.linear.x = vx
        odom.twist.twist.angular.z = vth
        self._odom_pub.publish(odom)

        t = TransformStamped()
        t.header.stamp = now.to_msg()
        t.header.frame_id = "odom"
        t.child_frame_id = "base_link"
        t.transform.translation.x = self._x
        t.transform.translation.y = self._y
        t.transform.translation.z = 0.0
        t.transform.rotation.z = math.sin(self._theta / 2.0)
        t.transform.rotation.w = math.cos(self._theta / 2.0)
        self._tf_broadcaster.sendTransform(t)

    def destroy_node(self):
        if self._serial and self._serial.is_open:
            try:
                self._send_line("V 0.00 0.00")
                time.sleep(0.1)
                self._serial.close()
            except Exception:
                pass
        super().destroy_node()


def main(args=None):
    rclpy.init(args=args)
    node = SerialBridge()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == "__main__":
    main()
