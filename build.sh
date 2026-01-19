# Builds the base docker image
docker build -f Dockerfile.base . --network=host -t depth_anything_3_ros2:base2
