ZENOH_CONFIG_OVERRIDE='listen/endpoints=["tcp/0.0.0.0:7447"]' ros2 run rmw_zenoh_cpp rmw_zenohd &
sleep 2
ros2 run ros1_bridge parameter_bridge &
sleep 2
ros2 daemon start
exec tail -f /dev/null