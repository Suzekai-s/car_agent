# Install script for directory: /home/szk/workspace/car_distributed/car_agent/src/diagnostics/diagnostic_common_diagnostics

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/home/szk/workspace/car_distributed/car_agent/install/diagnostic_common_diagnostics")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/diagnostic_common_diagnostics/environment" TYPE FILE FILES "/home/szk/workspace/car_distributed/car_agent/build/diagnostic_common_diagnostics/ament_cmake_environment_hooks/pythonpath.sh")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/diagnostic_common_diagnostics/environment" TYPE FILE FILES "/home/szk/workspace/car_distributed/car_agent/build/diagnostic_common_diagnostics/ament_cmake_environment_hooks/pythonpath.dsv")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/local/lib/python3.10/dist-packages/diagnostic_common_diagnostics-4.0.7-py3.10.egg-info" TYPE DIRECTORY FILES "/home/szk/workspace/car_distributed/car_agent/build/diagnostic_common_diagnostics/ament_cmake_python/diagnostic_common_diagnostics/diagnostic_common_diagnostics.egg-info/")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/local/lib/python3.10/dist-packages/diagnostic_common_diagnostics" TYPE DIRECTORY FILES "/home/szk/workspace/car_distributed/car_agent/src/diagnostics/diagnostic_common_diagnostics/diagnostic_common_diagnostics/" REGEX "/[^/]*\\.pyc$" EXCLUDE REGEX "/\\_\\_pycache\\_\\_$" EXCLUDE)
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  execute_process(
        COMMAND
        "/usr/bin/python3" "-m" "compileall"
        "/home/szk/workspace/car_distributed/car_agent/install/diagnostic_common_diagnostics/local/lib/python3.10/dist-packages/diagnostic_common_diagnostics"
      )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/diagnostic_common_diagnostics" TYPE PROGRAM FILES
    "/home/szk/workspace/car_distributed/car_agent/src/diagnostics/diagnostic_common_diagnostics/diagnostic_common_diagnostics/cpu_monitor.py"
    "/home/szk/workspace/car_distributed/car_agent/src/diagnostics/diagnostic_common_diagnostics/diagnostic_common_diagnostics/ntp_monitor.py"
    "/home/szk/workspace/car_distributed/car_agent/src/diagnostics/diagnostic_common_diagnostics/diagnostic_common_diagnostics/ram_monitor.py"
    "/home/szk/workspace/car_distributed/car_agent/src/diagnostics/diagnostic_common_diagnostics/diagnostic_common_diagnostics/sensors_monitor.py"
    "/home/szk/workspace/car_distributed/car_agent/src/diagnostics/diagnostic_common_diagnostics/diagnostic_common_diagnostics/hd_monitor.py"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/ament_index/resource_index/package_run_dependencies" TYPE FILE FILES "/home/szk/workspace/car_distributed/car_agent/build/diagnostic_common_diagnostics/ament_cmake_index/share/ament_index/resource_index/package_run_dependencies/diagnostic_common_diagnostics")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/ament_index/resource_index/parent_prefix_path" TYPE FILE FILES "/home/szk/workspace/car_distributed/car_agent/build/diagnostic_common_diagnostics/ament_cmake_index/share/ament_index/resource_index/parent_prefix_path/diagnostic_common_diagnostics")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/diagnostic_common_diagnostics/environment" TYPE FILE FILES "/opt/ros/humble/share/ament_cmake_core/cmake/environment_hooks/environment/ament_prefix_path.sh")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/diagnostic_common_diagnostics/environment" TYPE FILE FILES "/home/szk/workspace/car_distributed/car_agent/build/diagnostic_common_diagnostics/ament_cmake_environment_hooks/ament_prefix_path.dsv")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/diagnostic_common_diagnostics/environment" TYPE FILE FILES "/opt/ros/humble/share/ament_cmake_core/cmake/environment_hooks/environment/path.sh")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/diagnostic_common_diagnostics/environment" TYPE FILE FILES "/home/szk/workspace/car_distributed/car_agent/build/diagnostic_common_diagnostics/ament_cmake_environment_hooks/path.dsv")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/diagnostic_common_diagnostics" TYPE FILE FILES "/home/szk/workspace/car_distributed/car_agent/build/diagnostic_common_diagnostics/ament_cmake_environment_hooks/local_setup.bash")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/diagnostic_common_diagnostics" TYPE FILE FILES "/home/szk/workspace/car_distributed/car_agent/build/diagnostic_common_diagnostics/ament_cmake_environment_hooks/local_setup.sh")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/diagnostic_common_diagnostics" TYPE FILE FILES "/home/szk/workspace/car_distributed/car_agent/build/diagnostic_common_diagnostics/ament_cmake_environment_hooks/local_setup.zsh")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/diagnostic_common_diagnostics" TYPE FILE FILES "/home/szk/workspace/car_distributed/car_agent/build/diagnostic_common_diagnostics/ament_cmake_environment_hooks/local_setup.dsv")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/diagnostic_common_diagnostics" TYPE FILE FILES "/home/szk/workspace/car_distributed/car_agent/build/diagnostic_common_diagnostics/ament_cmake_environment_hooks/package.dsv")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/ament_index/resource_index/packages" TYPE FILE FILES "/home/szk/workspace/car_distributed/car_agent/build/diagnostic_common_diagnostics/ament_cmake_index/share/ament_index/resource_index/packages/diagnostic_common_diagnostics")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/diagnostic_common_diagnostics/cmake" TYPE FILE FILES
    "/home/szk/workspace/car_distributed/car_agent/build/diagnostic_common_diagnostics/ament_cmake_core/diagnostic_common_diagnosticsConfig.cmake"
    "/home/szk/workspace/car_distributed/car_agent/build/diagnostic_common_diagnostics/ament_cmake_core/diagnostic_common_diagnosticsConfig-version.cmake"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/diagnostic_common_diagnostics" TYPE FILE FILES "/home/szk/workspace/car_distributed/car_agent/src/diagnostics/diagnostic_common_diagnostics/package.xml")
endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/home/szk/workspace/car_distributed/car_agent/build/diagnostic_common_diagnostics/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
