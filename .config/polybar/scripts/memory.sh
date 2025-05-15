#!/bin/bash
# memory.sh - Display used and total memory

# Get memory info in megabytes
read total used <<< $(free -m | awk '/^Mem:/ {print $2, $3}')

echo " ${used}MB/${total}MB   "
