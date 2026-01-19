FROM depth_anything_3_ros2:base2

# Build depth anything
WORKDIR /ros2_ws
COPY Depth-Anything-3-ROS2 /ros2_ws/src/depth_anything_3_ros2
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && \
    colcon build --packages-select depth_anything_3_ros2 && \
    rm -rf build log"

# Build yolo world
COPY YOLO-World-ROS2 /ros2_ws/src/yolo_world_ros2
COPY yolov8l-world.pt /ros2_ws/yolov8l-world.pt
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && \
    colcon build --packages-up-to yolo_world_ros2 && \
    rm -rf build log"

# Build serenade
COPY Serenade-ROS2 /ros2_ws/src/serenade_ros2
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && \
    colcon build --packages-select serenade_ros2 && \
    rm -rf build log"

# Setup entrypoint and init script
RUN echo "source /ros_entrypoint.sh" >> ~/.bashrc
COPY ros_entrypoint.sh /ros_entrypoint.sh
COPY init.sh /init.sh
RUN chmod +x /ros_entrypoint.sh /init.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
