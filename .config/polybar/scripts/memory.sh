#!/bin/bash
# memory.sh - Display used and total memory

# Get memory info in megabytes
read total used <<< $(free -m | awk '/^Mem:/ {print $2, $3}')
#echo " ${used}MB/${total}MB   "

# Convert MB to GB
used_gb=$(awk "BEGIN {printf \"%.1f\", $used/1024}")
total_gb=$(awk "BEGIN {printf \"%.1f\", $total/1024}")

echo " ${used_gb}GB/${total_gb}GB   "
