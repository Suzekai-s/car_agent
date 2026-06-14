#!/usr/bin/env bash
# 一键编译 car_agent (上位机工作区)
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 如果还没有雷达驱动，先克隆
if [ ! -d "src/Lslidar_ROS2_driver" ]; then
    echo "[car_agent] 克隆 lslidar 雷达驱动..."
    git clone --depth 1 --branch M10P/N10P https://github.com/Lslidar/Lslidar_ROS2_driver.git src/Lslidar_ROS2_driver
fi

# 如果还没有 diagnostic_updater，先克隆
if [ ! -d "src/diagnostics" ]; then
    echo "[car_agent] 克隆 diagnostic_updater..."
    git clone --depth 1 --branch ros2-humble https://github.com/ros/diagnostics.git src/diagnostics
fi

source /opt/ros/humble/setup.bash
colcon build "$@"
source install/setup.bash

echo ""
echo "[car_agent] ✅ 编译完成"
echo "[car_agent] 启动命令: ros2 launch car_agent_bringup car_agent.launch.py"
