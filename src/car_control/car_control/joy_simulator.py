#!/usr/bin/env python3
"""手柄模拟器：在没有物理手柄时发送模拟的 joy 消息."""

import sys
import rclpy
from rclpy.node import Node
from sensor_msgs.msg import Joy


class JoySimulator(Node):
    def __init__(self):
        super().__init__("joy_simulator")
        self._pub = self.create_publisher(Joy, "/joy", 10)
        self._auto = "--auto" in sys.argv
        self._linear_x = 0.0
        self._angular_z = 0.0
        self._lb_pressed = False
        self._rb_pressed = False

        if self._auto:
            self._timer = self.create_timer(0.1, self._auto_loop)
            self._t = 0.0
            self.get_logger().info("自动模式: 模拟画圈运动")
        else:
            self._timer = self.create_timer(0.1, self._publish_joy)
            self.get_logger().info("交互模式 > ")

    def _publish_joy(self):
        msg = Joy()
        msg.header.stamp = self.get_clock().now().to_msg()
        msg.header.frame_id = "joy"
        msg.axes = [0.0, -self._linear_x, self._angular_z, 0.0, 0.0, 0.0]
        buttons = [0] * 11
        if self._lb_pressed:
            buttons[4] = 1
        if self._rb_pressed:
            buttons[5] = 1
        msg.buttons = buttons
        self._pub.publish(msg)

    def _auto_loop(self):
        self._t += 0.1
        if self._t < 3.0:
            self._lb_pressed = True
            self._linear_x = 0.0
            self._angular_z = 0.0
        elif self._t < 6.0:
            self._lb_pressed = True
            self._linear_x = 0.5
            self._angular_z = 0.0
        elif self._t < 9.0:
            self._lb_pressed = True
            self._linear_x = 0.5
            self._angular_z = 0.5
        elif self._t < 12.0:
            self._lb_pressed = True
            self._linear_x = -0.3
            self._angular_z = -0.5
        elif self._t < 13.0:
            self._lb_pressed = False
            self._linear_x = 0.5
            self._angular_z = 0.5
        else:
            self._t = 0.0
        self._publish_joy()


def main(args=None):
    rclpy.init(args=args)
    node = JoySimulator()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == "__main__":
    main()
