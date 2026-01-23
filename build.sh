# Builds the base docker image
docker build -f Dockerfile.gemini . --network=host -t depth_anything_3_ros2:gemini
