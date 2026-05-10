#! /usr/bin/
find . -type f -iname "*.wma" | while read -r file; do
    out="${file%.*}.m4a"

    ffmpeg -i "$file" \
        -map 0:a \
        -map 0:v? \
        -c:a aac \
        -b:a 256k \
        -c:v copy \
        -disposition:v attached_pic \
        "$out"

		rm "${file%.*}.wma"
		 
done
