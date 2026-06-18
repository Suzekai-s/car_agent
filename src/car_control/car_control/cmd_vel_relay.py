#!/usr/bin/env python3
"""cmd_vel_relay: 速度指令中继节点（限速 + 超时停车）."""

import rclpy
from rclpy.node import Node
from geometry_msgs.msg import Twist


class CmdVelRelay(Node):
    def __init__(self):
        super().__init__("cmd_vel_relay")
        self.declare_parameter("max_linear_speed", 1.0)
        self.declare_parameter("max_angular_speed", 2.0)
        self.declare_parameter("cmd_timeout", 0.5)

        self._last_cmd_time = self.get_clock().now()
        self._timer = self.create_timer(0.1, self._check_timeout)
        self._sub = self.create_subscription(Twist, "/cmd_vel", self._cmd_callback, 10)
        self._pub = self.create_publisher(Twist, "/car/cmd_vel", 10)
        self._print_count = 0

        self.get_logger().info("cmd_vel_relay 已启动")
        self.get_logger().info(
            f"  限速: linear<={self._get_param('max_linear_speed').value} m/s, "
            f"angular<={self._get_param('max_angular_speed').value} rad/s"
        )

    def _get_param(self, name):
        return self.get_parameter(name)

    def _clamp(self, value, limit):
        return max(-limit, min(limit, value))

    def _cmd_callback(self, msg: Twist):
        self._last_cmd_time = self.get_clock().now()
        max_l = self._get_param("max_linear_speed").value
        max_a = self._get_param("max_angular_speed").value
        relay = Twist()
        relay.linear.x = self._clamp(msg.linear.x, max_l)
        relay.angular.z = self._clamp(msg.angular.z, max_a)
        self._pub.publish(relay)
        self._print_count += 1
        if self._print_count % 20 == 0:
            self.get_logger().debug(
                f"linear.x={relay.linear.x:.2f}, angular.z={relay.angular.z:.2f}"
            )

    def _check_timeout(self):
        timeout = self._get_param("cmd_timeout").value
        elapsed = (self.get_clock().now() - self._last_cmd_time).nanoseconds / 1e9
        if elapsed > timeout:
            self._pub.publish(Twist())

    def destroy_node(self):
        try:
            self._pub.publish(Twist())
        except Exception:
            pass
        super().destroy_node()


def main(args=None):
    rclpy.init(args=args)
    node = CmdVelRelay()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == "__main__":
    main()
