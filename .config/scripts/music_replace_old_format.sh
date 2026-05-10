#!/usr/bin/env bash

src="/mnt/HDD_DATA/media/music"
dst="/mnt/samsung_a55/SD card/Music"

find "$src" -type f -name '*.m4a' | while read -r srcfile; do

    rel="${srcfile#$src/}"
    base="${rel%.m4a}"

    target_wma="$dst/$base.wma"
    target_m4a="$dst/$rel"

    if [[ -f "$target_wma" ]]; then

        mkdir -p "$(dirname "$target_m4a")"
				
				echo "COPYING $target_m4a"
        cp -v "$srcfile" "$target_m4a"

				echo "DELETING $target_wma"
        rm -v "$target_wma"
    fi
done
