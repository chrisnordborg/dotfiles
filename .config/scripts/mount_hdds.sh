#! /bin/bash

HDD1_DEST="/mnt/HDD_1"
HDD2_DEST="/mnt/HDD_2"

[[ -d "$HDD1_DEST" ]] || mkdir -p "$HDD1_DEST"
[[ -d "$HDD2_DEST" ]] || mkdir -p "$HDD2_DEST"

chown -R $USER:$USER "$HDD1_DEST" "$HDD2_DEST"


