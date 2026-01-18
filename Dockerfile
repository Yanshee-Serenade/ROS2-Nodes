# STAGE 1: Get the compiled bridge from your local builder
FROM ros-jazzy-ros1-bridge-builder:latest AS builder
# The builder image has the compiled artifacts. 
# We don't need to run commands here, just define the stage for COPY.

# STAGE 2: The Depth Anything V3 Image
FROM tillbeemelmanns/ros2-depth-anything-v3:latest-dev

# Copy the compiled bridge from the builder stage
# The builder README indicates the workspace is at /ros-jazzy-ros1-bridge (root directory)
COPY --from=builder /ros-jazzy-ros1-bridge /opt/ros-jazzy-ros1-bridge

# Install packages
ARG DEBIAN_FRONTEND=noninteractive
RUN echo 'Acquire::Retries "8";' > /etc/apt/apt.conf.d/80-retries \
    && apt-get update && apt-get install -y \
    libboost-thread1.83.0 \
    libboost-chrono1.83.0 \
    libboost-filesystem1.83.0 \
    ros-jazzy-example-interfaces \
    ros-jazzy-map-msgs \
    ros-jazzy-tf2-msgs \
    ros-jazzy-turtlesim \
    ros-jazzy-rviz2 \
    ros-jazzy-rosbag2 \
    ros-jazzy-rosbag2-storage-mcap \
    && rm -rf /var/lib/apt/lists/*

# Build DA3
RUN colcon build --packages-select depth_anything_v3 --cmake-args -DCMAKE_BUILD_TYPE=Release
# RUN source install/setup.bash && ./generate_engines.sh

# Copy the modified entrypoint
RUN echo "source /ros_entrypoint.sh" >> ~/.bashrc
COPY ros_entrypoint.sh /ros_entrypoint.sh
COPY init.sh /init.sh
ENTRYPOINT ["/ros_entrypoint.sh"]
