# Serenade ROS2 Nodes

- Depth-Anything-3-ROS2
- YOLO-World-ROS2
- Serenade-ROS2

## Build

1. Download or optionally cache models
    - Download `yolov8l-world.pt` in project root
    - Cache `ViT-B-32.pt` in `~/.cache/clip`
    - Cache `depth-anything/DA3-BASE` in `~/.cache/huggingface`
    - Cache `Qwen/Qwen3-VL-8B-Instruct` in `~/.cache/huggingface`
2. Build base image with `./build.sh`
3. Build node with `docker compose build`

## Run

### Depth-Anything-3

```
ros2 launch depth_anything_3_ros2 depth_anything_3.launch.py \
  image_topic:=/camera/image_raw \
  camera_info_topic:=/camera/camera_info \
  model_name:=depth-anything/DA3-BASE \
  device:=cuda
```

### YOLO-World

> [!WARNING]
> If you're not using default model, also change it in:
> 
> `YOLO-World-ROS2/yolo_world_ros2/yolo_world_ros2/yolo_world_ros2.py`

```
ros2 launch yolo_world_ros2 yolo_world_ros2_launch.py \
  color_image:=/camera/image_raw \
  color_camerainfo:=/camera/camera_info
ros2 service call /yolo_world/execute std_srvs/srv/SetBool "data: True"
ros2 service call /yolo_world/classes yolo_world_interfaces/srv/SetClasses \
"{classes: [chair, phone, tablet, pencil], conf: 0.25}"
```

### Serenade

```
# Run the VLM server
# Generates /answer from /question
ros2 launch serenade_ros2 vlm_server.launch.py \
  image_topic:=/camera/image_slow \
  model_name:=Qwen/Qwen3-VL-8B-Instruct \
  max_new_tokens:=256

# Run the chatbot
# Generates /question from ASR
# Speaks /answer via TTS
ros2 launch serenade_ros2 chatbot.launch.py

# (Test) Make robot walk forever
ros2 launch serenade_ros2 walker.launch.py

# (Test) Validate point cloud in a stream manner
ros2 launch serenade_ros2 pointcloud_validator.launch.py
```

Test VLM:

```
# Terminal 1: interactively publish question
ros2 topic pub /question std_msgs/msg/String "data: '你看到了什么？请简短回答'" -1

# Terminal 2: streams VLM reply
ros2 topic echo /answer
```
