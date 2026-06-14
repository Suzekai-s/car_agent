#!/usr/bin/env bash
# car_agent 环境加载
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source /opt/ros/humble/setup.bash

if [ -f "$SCRIPT_DIR/install/setup.bash" ]; then
    source "$SCRIPT_DIR/install/setup.bash"
fi

export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export ROS_DOMAIN_ID=42
export ROS_LOCALHOST_ONLY=0

echo "[car_agent] ✅ 环境就绪 (DOMAIN_ID=42, CycloneDDS)"
echo "[car_agent] 启动: ros2 launch car_agent_bringup car_agent.launch.py"
