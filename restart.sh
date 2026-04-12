#!/bin/sh
set -eu

stop_processes() {
  label="$1"
  pattern="$2"

  if pgrep -f "$pattern" >/dev/null 2>&1; then
    echo "Stopping $label..."
    pkill -TERM -f "$pattern" || true
    sleep 1

    if pgrep -f "$pattern" >/dev/null 2>&1; then
      echo "Force stopping $label..."
      pkill -KILL -f "$pattern" || true
    fi
  else
    echo "$label is not running."
  fi
}

stop_processes "ros1_bridge parameter_bridge" "[p]arameter_bridge"
stop_processes "rmw_zenohd" "[r]mw_zenohd"

echo "Restarting ROS2 daemon..."
ros2 daemon stop || true
ros2 daemon start

echo "Starting rmw_zenohd..."
ZENOH_CONFIG_OVERRIDE='listen/endpoints=["tcp/0.0.0.0:7447"]' ros2 run rmw_zenoh_cpp rmw_zenohd &
sleep 2

echo "Starting ros1_bridge parameter_bridge..."
ros2 run ros1_bridge parameter_bridge &
sleep 2

ros2 daemon start
echo "Restart complete."
