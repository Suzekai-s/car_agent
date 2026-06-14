#!/usr/bin/env bash
# 一键编译 car_agent (上位机工作区)
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

source /opt/ros/humble/setup.bash
colcon build "$@"
source install/setup.bash

echo ""
echo "[car_agent] ✅ 编译完成"
echo "[car_agent] 启动命令: ros2 launch car_agent_bringup car_agent.launch.py"
