#!/bin/bash

for i in in/*; do
output=$(basename "$i")
ffmpeg -i "$i" -map 0:a -map_metadata -1 -c copy out/"${output}"
done
