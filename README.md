# Serenade ROS2 Nodes

- Depth-Anything-3-ROS2
- YOLO-World-ROS2

## Build

1. Download models
    - Depth-Anything-3: Download `DA3-Base` in `.cache/huggingface`
    - YOLO-World: Download `yolov8l-world.pt` in project root
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
> `YOLO-World-ROS2/yolo_world_ros2/yolo_world_ros2/yolo_world_ros2.py`

```
ros2 launch yolo_world_ros2 yolo_world_ros2_launch.py \
  color_image:=/camera/image_raw \
  color_camerainfo:=/camera/camera_info
ros2 service call /yolo_world/execute std_srvs/srv/SetBool "data: True"
ros2 service call /yolo_world/classes yolo_world_interfaces/srv/SetClasses \
"{classes: [chair, phone, tablet, pencil], conf: 0.25}"
```
