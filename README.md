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
# Run DA3 and the RDF point cloud used for walk limits
ros2 launch serenade_ros2 deps.launch.py \
  image_topic:=/camera/image_raw \
  camera_info_topic:=/camera/camera_info \
  point_cloud_topic:=/point_cloud

# Run the Anthropic-compatible agent
# Subscribes to /question, publishes /answer, and calls /walker_command tools
ros2 launch serenade_ros2 vlm_server.launch.py \
  image_topic:=/camera/image_raw \
  point_cloud_topic:=/point_cloud \
  auth_token:=YOUR_TOKEN \
  base_url:=https://api.anthropic.com \
  model:=claude-sonnet-4-5 \
  max_tokens:=8000

# Run the chatbot
# Publishes /question from ASR
# Speaks /answer via TTS
ros2 launch serenade_ros2 chatbot.launch.py

# Run the command-driven walker
# Subscribes to /walker_command and publishes /walker_result
ros2 launch serenade_ros2 walker.launch.py
```

Test agent:

```
# Terminal 1: interactively publish prompts
ros2 topic pub /question std_msgs/msg/String "data: '你看到了什么？请简短回答'" -1
ros2 topic pub /question std_msgs/msg/String "data: '请走向离你最远的椅子'" -1

# Terminal 2: spoken tool text
ros2 topic echo /answer

# Terminal 3: walker command/result JSON
ros2 topic echo /walker_command
ros2 topic echo /walker_result
```

Agent tools:

```
# SPIN(word, degree): say a short phrase and rotate in place; 20 degrees = 1 second
# WALK(word, meter): say a short phrase and walk forward only; 0.1 m = 3 seconds
# WAIT(word, sec): say a short phrase and wait; sec must be an integer multiple of 1
# FINISH(word): say a short phrase and end the current task
```

Question format:

```
# Any new prompt on /question interrupts the active agent/walker tool if one is running.
# It also interrupts WAIT, so WAIT(..., 1000) can be used after the agent asks a question.
ros2 topic pub /question std_msgs/msg/String "data: '请走向离你最远的奶龙'" -1
ros2 topic pub /question std_msgs/msg/String "data: '停一下，看看左边'" -1
```
