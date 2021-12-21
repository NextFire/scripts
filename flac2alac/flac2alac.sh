#!/bin/bash

cd "$(dirname "$0")"
for i in in/*.flac; do
output=$(basename "$i")
ffmpeg -i "$i" -c:v copy -c:a alac out/"${output/.flac}.m4a"
done
