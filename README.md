# Serenade ROS2 Nodes

- Depth-Anything-3-ROS2
- YOLO-World-ROS2
- Serenade-ROS2

## Build

1. Make sure you've set `$UID`, `$GID` and `$USER` correct
2. Download or optionally cache models
    - Download `yolov8l-world.pt` in project root
    - Cache `ViT-B-32.pt` in `~/.cache/clip`
    - Cache `depth-anything/DA3-BASE` in `~/.cache/huggingface`
    - Cache `Qwen/Qwen3-VL-8B-Instruct` in `~/.cache/huggingface`
3. Build base image with `docker build -f Dockerfile.gemini . --network=host -t depth_anything_3_ros2:gemini`
4. Build node with `docker compose build`

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

> [!WARNING]
> If you use chatbot, you should change `serenade_chatbot/main.py` L37
> to your actual Yanshee robot IP!

```
# Run the VLM server
# Generates /answer from /question
ros2 launch serenade_ros2 vlm_server.launch.py \
  image_topic:=/yolo_world/annotated_image \
  model_name:=Qwen/Qwen3-VL-4B-Instruct \
  max_new_tokens:=256

# Run the chatbot
# Generates /question from ASR
# Speaks /answer via TTS
ros2 launch serenade_ros2 chatbot.launch.py

# (Test) Make robot walk forever
ros2 launch serenade_ros2 walker.launch.py
```

Test VLM:

```
# Terminal 1: interactively publish question
ros2 topic pub /question std_msgs/msg/String "data: '你看到了什么？请简短回答'" -1
ros2 topic pub /question std_msgs/msg/String "data: '请走向离你最远的椅子'" -1

# Terminal 2: streams VLM reply
ros2 topic echo /answer
```

Question format:

```
# Normal messages that cannot be interrupted
ros2 topic pub /question std_msgs/msg/String "data: '请走向离你最远的奶龙'" -1

# An interruptible message
ros2 topic pub /question std_msgs/msg/String "data: '请简要概括现在的情况，并决定下一步行动'" -1
```
