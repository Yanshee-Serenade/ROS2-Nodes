FROM depth_anything_3_ros2:gemini

# Create a non-root user with the same UID/GID as the host
ARG USERNAME=dockeruser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create user and group
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
USER $USERNAME

# Set working directory
WORKDIR /ros2_ws

# Copy all ROS2 packages to src directory
COPY . /ros2_ws/src

# Build all packages at once using --symlink-install
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && \
    colcon build --symlink-install"

# Set up environment variables and entrypoint script
RUN echo "source /ros2_ws/src/ros_entrypoint.sh" >> ~/.bashrc

# Set environment variables and entrypoint script
ENTRYPOINT ["/ros2_ws/src/ros_entrypoint.sh"]