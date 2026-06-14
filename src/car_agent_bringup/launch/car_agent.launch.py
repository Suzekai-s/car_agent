"""上位机（车端）启动文件 — 只启动传感器驱动 + 串口通信.

部署在车上的 Ubuntu 系统，通过 ROS2 DDS 将传感器数据发往主机。

用法:
  ros2 launch car_agent_bringup car_agent.launch.py
  ros2 launch car_agent_bringup car_agent.launch.py camera:=false
  ros2 launch car_agent_bringup car_agent.launch.py serial_port:=/dev/ttyUSB0
  ros2 launch car_agent_bringup car_agent.launch.py joy:=false
"""

from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument
from launch.conditions import IfCondition
from launch.substitutions import LaunchConfiguration, PathJoinSubstitution
from launch_ros.actions import Node
from launch_ros.substitutions import FindPackageShare


def generate_launch_description():
    bringup_dir = FindPackageShare("car_agent_bringup")

    declare_camera = DeclareLaunchArgument("camera", default_value="true")
    declare_lidar = DeclareLaunchArgument("lidar", default_value="true")
    declare_joy = DeclareLaunchArgument("joy", default_value="true")
    declare_serial = DeclareLaunchArgument("serial_port", default_value="auto")

    # ── LiDAR ──
    lidar_node = Node(
        package="lslidar_driver", executable="lslidar_driver_node",
        name="lslidar_driver_node", output="screen",
        parameters=[PathJoinSubstitution([bringup_dir, "config", "lsn10p.yaml"])],
        condition=IfCondition(LaunchConfiguration("lidar")),
    )

    # ── 摄像头 ──
    camera_node = Node(
        package="v4l2_camera", executable="v4l2_camera_node",
        name="v4l2_camera_node", output="screen",
        parameters=[PathJoinSubstitution([bringup_dir, "config", "usb_cam_params.yaml"])],
        condition=IfCondition(LaunchConfiguration("camera")),
    )

    # ── 手柄 ──
    joy_node = Node(
        package="joy", executable="joy_node", name="joy_node", output="screen",
        parameters=[{"dev": "/dev/input/js0", "deadzone": 0.05, "autorepeat_rate": 20.0}],
        condition=IfCondition(LaunchConfiguration("joy")),
    )
    teleop_node = Node(
        package="teleop_twist_joy", executable="teleop_node",
        name="teleop_twist_joy_node", output="screen",
        parameters=[PathJoinSubstitution([bringup_dir, "config", "car_joy.yaml"])],
        condition=IfCondition(LaunchConfiguration("joy")),
    )

    # ── 限速 ──
    relay_node = Node(
        package="car_control", executable="cmd_vel_relay",
        name="cmd_vel_relay", output="screen",
    )

    # ── 串口桥接（含里程计） ──
    serial_node = Node(
        package="car_control", executable="serial_bridge",
        name="serial_bridge", output="screen",
        parameters=[{
            "port": LaunchConfiguration("serial_port"),
            "baudrate": 115200,
            "heartbeat_interval": 0.5,
            "wheel_diameter": 0.15,
            "track_width": 0.35,
            "ticks_per_rev": 500,
            "gear_ratio": 30.0,
        }],
    )

    # ── 静态 TF ──
    static_tf_laser = Node(
        package="tf2_ros", executable="static_transform_publisher",
        name="static_tf_laser",
        arguments=["0", "0", "0.1", "0", "0", "0", "base_link", "laser_link"],
    )
    static_tf_camera = Node(
        package="tf2_ros", executable="static_transform_publisher",
        name="static_tf_camera",
        arguments=["0.3", "0", "0.15", "0", "0", "0", "base_link", "camera_link"],
    )

    return LaunchDescription([
        declare_camera, declare_lidar, declare_joy, declare_serial,
        lidar_node, camera_node,
        joy_node, teleop_node,
        relay_node, serial_node,
        static_tf_laser, static_tf_camera,
    ])
