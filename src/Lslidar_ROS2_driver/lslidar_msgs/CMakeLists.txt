cmake_minimum_required(VERSION 3.5)
project(lslidar_msgs)

find_package(ament_cmake REQUIRED)
find_package(builtin_interfaces REQUIRED)
find_package(std_msgs REQUIRED)
find_package(sensor_msgs REQUIRED)
find_package(rosidl_default_generators REQUIRED)

rosidl_generate_interfaces(lslidar_msgs
  "msg/LslidarDifop.msg"
  "msg/LslidarPacket.msg"
  "msg/LslidarPoint.msg"
  "msg/LslidarScan.msg"
  "msg/LslidarSweep.msg"
  DEPENDENCIES builtin_interfaces std_msgs sensor_msgs
)

ament_export_dependencies(rosidl_default_runtime)
ament_package()
