FROM depth_anything_3_ros2:base

# Build The Workspace
WORKDIR /ros2_ws
COPY Depth-Anything-3-ROS2 /ros2_ws/src/depth_anything_3_ros2

# Source ROS and build
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && \
    colcon build --symlink-install --packages-select depth_anything_3_ros2"

# Setup entrypoint and init script
RUN echo "source /ros_entrypoint.sh" >> ~/.bashrc
COPY ros_entrypoint.sh /ros_entrypoint.sh
COPY init.sh /init.sh
RUN chmod +x /ros_entrypoint.sh /init.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
