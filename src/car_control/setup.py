import os
from glob import glob
from setuptools import find_packages, setup

package_name = "car_control"

setup(
    name=package_name,
    version="0.0.0",
    packages=find_packages(exclude=["test"]),
    data_files=[
        ("share/ament_index/resource_index/packages", ["resource/" + package_name]),
        ("share/" + package_name, ["package.xml"]),
        (os.path.join("share", package_name, "launch"), glob("launch/*.launch.py")),
    ],
    install_requires=["setuptools"],
    zip_safe=True,
    maintainer="user",
    maintainer_email="user@example.com",
    description="Car agent control logic: relay, serial bridge, joy simulator",
    license="Apache-2.0",
    entry_points={
        "console_scripts": [
            "cmd_vel_relay = car_control.cmd_vel_relay:main",
            "serial_bridge = car_control.serial_bridge:main",
            "joy_simulator = car_control.joy_simulator:main",
        ],
    },
)
