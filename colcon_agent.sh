#!/usr/bin/env bash
# 一键编译 car_agent (上位机工作区)
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

source /opt/ros/humble/setup.bash
colcon build "$@"

# ── 修复: 为 Python 包创建 lib/<pkg>/ 符号链接 ──
# ros2 run 在 lib/<pkg>/ 中查找可执行文件，但 ament_python
# 把入口脚本装到了 bin/。此修复确保 ros2 run 能找到它们。
for pkg_dir in install/*/; do
  pkg=$(basename "$pkg_dir")
  if [ -d "$pkg_dir/bin" ] && [ ! -d "$pkg_dir/lib/$pkg" ]; then
    mkdir -p "$pkg_dir/lib/$pkg"
    for f in "$pkg_dir/bin/"*; do
      f_abs="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
      ln -sf "$f_abs" "$pkg_dir/lib/$pkg/"
    done
  fi
done

source install/setup.bash

echo ""
echo "[car_agent] ✅ 编译完成"
echo "[car_agent] 启动命令: ros2 launch car_agent_bringup car_agent.launch.py"
