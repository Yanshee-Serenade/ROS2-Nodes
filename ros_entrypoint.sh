#!/bin/bash

# 1. Source Base ROS 2
source "/opt/ros/humble/setup.bash"

# 2. Source the DA3 workspace (from the base image)
if [ -f "/ros2_ws/install/setup.bash" ]; then
    source "/ros2_ws/install/setup.bash"
fi

# 3. Source the Custom Message Overlays we just copied
if [ -f "/opt/custom_msgs/control_msgs_ros2/install/local_setup.bash" ]; then
    source "/opt/custom_msgs/control_msgs_ros2/install/local_setup.bash"
fi
if [ -f "/opt/custom_msgs/custom_action/install/local_setup.bash" ]; then
    source "/opt/custom_msgs/custom_action/install/local_setup.bash"
fi

# 4. Source the Bridge
source "/opt/ros-humble-ros1-bridge/install/local_setup.bash"

# 5. Environment variables
export RMW_IMPLEMENTATION=rmw_zenoh_cpp

if [ $# -gt 0 ]; then
    exec "$@"
fi
