#!/bin/bash

for i in *.mkv; do
output=$(basename "$i")
ffmpeg -i "$i" -map 0:s:0 -c copy "${output/.mkv}.ass"
done