#!/bin/bash
# cpu.sh - Returns CPU usage percentage

# Get the CPU usage percentage using the `top` command
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
echo " ${cpu_usage}%   "
