#!/bin/bash

# Read the last saved directory or fall back to $HOME
target_dir=$(cat /tmp/last_terminal_dir 2>/dev/null || echo "$HOME")

# Launch terminal in that directory
kitty --directory "$target_dir"

