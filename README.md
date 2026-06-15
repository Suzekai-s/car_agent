# car_agent — 车载上位机

部署在车载 Ubuntu 系统上（Arm / x86 单板计算机），负责**传感器驱动 + 串口通信 + 安全保护**。

## 系统架构

```
┌────────────────────────────────────────────────────────┐
│  car_agent（Ubuntu + ROS 2 Humble）                     │
│                                                         │
│  ┌──────────────┐  /scan        ┌──────────────────┐   │
│  │ lslidar_drv  │ ─────────────▶│  CycloneDDS      │   │
│  │ （镭神激光雷达）│               │  ROS_DOMAIN_ID=42│   │
│  ├──────────────┤  /image_raw   │                  │   │
│  │ v4l2_camera  │ ─────────────▶│  → car_host      │   │
│  │ （USB摄像头）  │               │  （SLAM/Nav/RViz）│   │
│  ├──────────────┤  /odom + tf   │                  │   │
│  │ serial_bridge│ ◀─────────────│                  │   │
│  │ （串口桥接）  │  /car/cmd_vel │                  │   │
│  ├──────────────┤               └──────────────────┘   │
│  │ cmd_vel_relay│ ◀── /cmd_vel                         │
│  │ （限速中继）  │      （来自主机或手柄）               │
│  ├──────────────┤                                       │
│  │ joy + teleop │ ──▶ /cmd_vel（手柄本地操控）         │
│  └──────┬───────┘                                       │
│         │ V/H 指令（115200 8N1）                        │
│         ▼                                               │
│  ┌──────────────┐                                       │
│  │ STM32 下位机  │                                       │
│  │ （电机驱动）  │                                       │
│  └──────────────┘                                       │
└────────────────────────────────────────────────────────┘
```

## 目录结构

```
car_agent/
├── setup.sh                       # 环境初始化（只需跑一次）
├── colcon_agent.sh                # 一键编译
│
└── src/
    ├── Lslidar_ROS2_driver/       # 镭神 LiDAR 驱动（第三方）
    │   ├── lslidar_msgs/          #   雷达消息定义
    │   │   └── msg/ （5 个 .msg 文件）
    │   └── lslidar_driver/        #   雷达驱动 C++ 节点
    │
    ├── car_control/               # 控制逻辑（纯 Python，免编译）
    │   └── car_control/
    │       ├── serial_bridge.py   #    串口桥接 + 里程计
    │       ├── cmd_vel_relay.py   #    速度限速 + 超时停车
    │       └── joy_simulator.py   #    手柄模拟器（调试用）
    │
    └── car_agent_bringup/         # 启动文件 + 配置
        ├── launch/car_agent.launch.py
        └── config/（雷达 / 手柄 / 摄像头参数）
```

## 节点详解

### 1. LiDAR 驱动（`lslidar_driver_node`）

镭神 M10 / N10 系列激光雷达驱动。

| 参数 | 说明 |
|------|------|
| 接口 | 串口（默认 `/dev/ttyACM0`）或网口（默认 `192.168.1.200:2368`） |
| 发布 | `/scan`（LaserScan）、`/lslidar_point_cloud`（PointCloud2） |
| 切换型号 | 修改 `lsn10p.yaml` 中的 `lidar_name`：`M10`、`M10_P`、`N10` 等 |

```bash
# 启用/禁用
ros2 launch ... lidar:=false
```

> **注意**：该包依赖 `diagnostic_updater`，colcon 会自动从 apt 拉取，无需手动处理。

### 2. 摄像头（`v4l2_camera_node`）

ROS 2 官方 USB 摄像头驱动。

| 参数 | 说明 |
|------|------|
| 发布 | `/image_raw`、`/camera_info` |
| 配置 | `usb_cam_params.yaml`（默认 MJPG 640×480 @30fps） |

```bash
# 启用/禁用
ros2 launch ... camera:=false
```

### 3. 串口桥接（`serial_bridge`）

STM32 下位机之间的双向通信 + 里程计推算。

**通信协议（115200 8N1 纯文本）：**

| 方向 | 格式 | 频率 | 说明 |
|------|------|------|------|
| 上位机→下位机 | `V <linear_x> <angular_z>\n` | 随控制指令 | 速度指令（m/s, rad/s） |
| 上位机→下位机 | `H <timestamp_ms>\n` | 每 500ms | 心跳保活 |
| 下位机→上位机 | `E <left> <right>\n` | 50Hz | 编码器累计脉冲值 |

**里程计参数（`wheel_diameter`、`track_width`、`ticks_per_rev`、`gear_ratio`）：**

里程计精度直接影响 SLAM 建图和导航效果，**请根据实际车体测量标定**。

```bash
# 传递参数
ros2 launch car_agent_bringup car_agent.launch.py \
  serial_bridge.wheel_diameter:=0.15 \
  serial_bridge.track_width:=0.35 \
  serial_bridge.ticks_per_rev:=500 \
  serial_bridge.gear_ratio:=30.0
```

### 4. 速度中继（`cmd_vel_relay`）

安全保护节点，订阅 `/cmd_vel`，发布限速后的 `/car/cmd_vel`。

| 功能 | 默认值 |
|------|--------|
| 最大线速度 | 1.5 m/s |
| 最大角速度 | 2.0 rad/s |
| 超时停车 | 0.5 秒无指令 → 自动刹车 |

### 5. 手柄操控（可选）

| 节点 | 说明 |
|------|------|
| `joy_node` | 读取 `/dev/input/js0` |
| `teleop_twist_joy` | 按键→`/cmd_vel` |

**按键映射：**
- LB（4）= 使能键，RB（5）= 加速键
- 左摇杆：前进/后退，右摇杆：转向

```bash
# 启用/禁用
ros2 launch ... joy:=false
```

## 快速开始

### 硬件需求

- Ubuntu 22.04 + ROS 2 Humble（已安装）
- 镭神 LiDAR × 1（USB 或网口）
- USB 摄像头 × 1（可选）
- USB 手柄 × 1（可选）

### 首次初始化

```bash
cd ~/workspace/car_agent
bash setup.sh
```

脚本自动完成：安装系统依赖 → 配置 DDS 环境变量 → 编译。

### 手动分步

```bash
# 1. 安装依赖
sudo apt update
sudo apt install -y \
  libpcap-dev \
  ros-humble-joy \
  ros-humble-teleop-twist-joy \
  ros-humble-v4l2-camera \
  ros-humble-rmw-cyclonedds-cpp \
  ros-humble-tf2-ros

# 2. DDS 环境变量
echo -e '\nexport RMW_IMPLEMENTATION=rmw_cyclonedds_cpp\nexport ROS_DOMAIN_ID=42\nexport ROS_LOCALHOST_ONLY=0' >> ~/.bashrc
source ~/.bashrc

# 3. 编译
source /opt/ros/humble/setup.bash
colcon build --symlink-install
source install/setup.bash
```

### 启动

```bash
ros2 launch car_agent_bringup car_agent.launch.py

# 常用变体
ros2 launch car_agent_bringup car_agent.launch.py camera:=false joy:=false          # 仅雷达 + 串口
ros2 launch car_agent_bringup car_agent.launch.py serial_port:=/dev/ttyUSB0        # 指定串口
ros2 launch car_agent_bringup car_agent.launch.py joy:=false serial_port:=none     # 仅雷达（调试）
```

### 验证

```bash
ros2 topic list
# 预期：/scan /odom /tf /cmd_vel /car/cmd_vel /image_raw ...

ros2 topic echo /scan --once
# 应输出雷达扫描数据
```

## 每日使用流程

### 每天开车时

```bash
# 1. 加载环境（如果已加到 bashrc 则跳过）
source install/setup.bash

# 2. 启动（传感器 + 串口）
ros2 launch car_agent_bringup car_agent.launch.py
```

如果你只想看雷达数据（不接 STM32）：

```bash
ros2 launch car_agent_bringup car_agent.launch.py joy:=false camera:=false serial_port:=none
```

### 调试常用命令

```bash
# 查看所有话题
ros2 topic list

# 看雷达数据
ros2 topic echo /scan --once

# 看里程计
ros2 topic echo /odom

# 发送测试速度指令
ros2 topic pub --once /cmd_vel geometry_msgs/msg/Twist \
  "{linear: {x: 0.3}, angular: {z: 0.0}}"

# 查看节点状态
ros2 node list
```

### 免 source 配置

每次新开终端都要重新 source，可以**加到 bashrc 自动加载**：

```bash
echo 'source ~/Desktop/workspace/car_agent/install/setup.bash' >> ~/.bashrc
```

以后每次打开终端直接可用。

## DDS 网络

与 `car_host` 通信需满足：

| 条件 | 说明 |
|------|------|
| 网络 | 两台机器在同一局域网（互相能 ping 通） |
| RMW | 都是 `rmw_cyclonedds_cpp` |
| Domain ID | 都是 `42` |
| 主机侧 | 需配置 Peers 单播指向上位机 IP |

详见 [`car_host/`](../car_host/README.md) 和 [`docs/NETWORK_SETUP.md`](../docs/NETWORK_SETUP.md)。

## 安全机制（三级保护）

```
主机 / 手柄 ──→ cmd_vel_relay ──→ serial_bridge ──→ STM32
                 0.5s 超时       2s 超时        2s 超时
                 自动刹车         自动刹车        强制断电
```

- 第一级：`cmd_vel_relay` — 0.5 秒无遥控指令 → 发零速
- 第二级：`serial_bridge` — 2 秒无新指令 → 串口发 `V 0.00 0.00`
- 第三级：STM32 固件 — 2 秒收不到任何数据 → 直接切断电机

## 常见问题

**Q：编译 `lslidar_msgs` 报 `list index out of range`**
A：工作路径包含中文字符。改用纯英文路径。

**Q：雷达报 `open_port ... OK` 后又报 `error`**
A：串口被多个节点同时占用。用 `serial_port:=none` 禁用串口桥接后单独调试雷达。

**Q：`/dev/ttyACM0` 权限不足**
A：`sudo usermod -a -G dialout $USER`，注销后重新登录。

**Q：手柄没反应**
A：检查 `/dev/input/js0` 是否存在。用 `ls /dev/input/` 确认设备名，修改 launch 中的 `dev` 参数。
