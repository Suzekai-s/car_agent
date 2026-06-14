#!/usr/bin/env bash
# car_agent 环境初始化脚本（在上位机上只跑一次）
# 安装所有系统级依赖 + 编译

set -e

echo "========================================"
echo " car_agent — 上位机环境初始化"
echo "========================================"

# 1. 安装系统依赖
echo ""
echo "[1/3] 安装 ROS2 依赖包..."
sudo apt update
sudo apt install -y \
  libpcap-dev \
  ros-humble-joy \
  ros-humble-teleop-twist-joy \
  ros-humble-v4l2-camera \
  ros-humble-rmw-cyclonedds-cpp \
  ros-humble-tf2-ros \
  ros-humble-sensor-msgs

# 2. 设置 DDS 环境变量
echo ""
echo "[2/3] 配置 DDS 网络环境..."
if ! grep -q "ROS_DOMAIN_ID=42" ~/.bashrc; then
    echo -e '\nexport RMW_IMPLEMENTATION=rmw_cyclonedds_cpp\nexport ROS_DOMAIN_ID=42\nexport ROS_LOCALHOST_ONLY=0' >> ~/.bashrc
    echo "  已添加到 ~/.bashrc"
else
    echo "  已存在，跳过"
fi

# 3. 编译
echo ""
echo "[3/3] 编译 car_agent..."
bash colcon_agent.sh

echo ""
echo "========================================"
echo "✅ 初始化完成！"
echo "启动: source setup.bash"
echo "运行: ros2 launch car_agent_bringup car_agent.launch.py"
echo "========================================"
