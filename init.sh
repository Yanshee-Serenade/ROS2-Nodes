ZENOH_CONFIG_OVERRIDE='listen/endpoints=["tcp/0.0.0.0:7447"]' ros2 run rmw_zenoh_cpp rmw_zenohd &
sleep 2
export ZENOH_CONFIG_OVERRIDE='connect/endpoints=["tcp/127.0.0.1:7447"]'
ros2 run ros1_bridge parameter_bridge
