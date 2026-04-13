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

echo "Stopping ROS2 daemon..."
ros2 daemon stop || true

echo "Shutdown complete."
