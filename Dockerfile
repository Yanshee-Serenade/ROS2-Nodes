# STAGE 1: Get the compiled bridge AND the workspaces from your local builder
FROM ros-humble-ros1-bridge-builder:latest AS builder

# STAGE 2: The Depth Anything V3 Image
FROM depth_anything_3_ros2:gpu

# -----------------------------------------------------------------------
# 1. Install Standard Apt Dependencies
# -----------------------------------------------------------------------
ARG DEBIAN_FRONTEND=noninteractive
RUN echo 'Acquire::Retries "8";' > /etc/apt/apt.conf.d/80-retries \
    && apt-get update && apt-get install -y \
    libboost-regex1.74.0 \
    libboost-thread1.74.0 \
    libboost-chrono1.74.0 \
    libboost-filesystem1.74.0 \
    ros-humble-example-interfaces \
    ros-humble-map-msgs \
    ros-humble-tf2-msgs \
    ros-humble-control-msgs \
    ros-humble-sensor-msgs \
    ros-humble-geometry-msgs \
    ros-humble-std-msgs \
    ros-humble-turtlesim \
    ros-humble-action-tutorials-interfaces \
    ros-humble-octomap-msgs \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------
# 2. Copy the Bridge Binary
# -----------------------------------------------------------------------
COPY --from=builder /ros-humble-ros1-bridge /opt/ros-humble-ros1-bridge

# -----------------------------------------------------------------------
# 3. Copy Custom Built Message Libraries (The Missing Link)
# -----------------------------------------------------------------------
# The builder compiled custom messages (control_msgs_ros2, octomap, etc.) 
# We need those generated shared libraries for the bridge to link against.

# Copy control_msgs (ROS2 version) compiled in builder
COPY --from=builder /control_msgs_ros2/install /opt/custom_msgs/control_msgs_ros2/install

# Copy octomap_msgs (if it was built in ROS2 path in builder)
# (Note: standard apt install might cover this, but safe to copy if built from source)
# COPY --from=builder /octomap_msgs/install /opt/custom_msgs/octomap_msgs/install

# Copy custom action mapping if present
COPY --from=builder /custom_action/install /opt/custom_msgs/custom_action/install

# -----------------------------------------------------------------------
# 4. Setup Entrypoint
# -----------------------------------------------------------------------
COPY ros_entrypoint.sh /ros_entrypoint.sh
COPY init.sh /init.sh
RUN chmod +x /ros_entrypoint.sh /init.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
