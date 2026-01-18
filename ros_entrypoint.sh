#!/bin/bash
set -e

# 1. Source System ROS (Jazzy)
source /opt/ros/$ROS_DISTRO/setup.bash

# 2. Source Base Image Workspace (if exists)
[[ -f /opt/ws_base_image/install/setup.bash ]] && source /opt/ws_base_image/install/setup.bash
[[ -f $WORKSPACE/install/setup.bash ]] && source $WORKSPACE/install/setup.bash

# 3. Source The ROS 1 Bridge
if [[ -f /opt/ros-jazzy-ros1-bridge/install/local_setup.bash ]]; then
    source /opt/ros-jazzy-ros1-bridge/install/local_setup.bash
    echo "Sourced ros-jazzy-ros1-bridge"
fi

# IMPORTANT: execute the command passed to the script
exec "$@"
