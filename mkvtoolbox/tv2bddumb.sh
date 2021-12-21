#!/bin/bash

cd "$(dirname "$0")"
mkdir 3out
for i in $(seq -f "%02g" 1 $(ls 2raw | wc -l))
do
  src=$(find 1source -regex ".*[^0-9S]${i}[^0-9].*")
  raw=$(find 2raw -regex ".*[^0-9S]${i}[^0-9].*")
  ffmpeg -y -i "$raw" -i "$src" -map 0 -map 1:s -map 1:t:? -c copy -disposition:s:0 default -metadata:s:s:0 language=fre "3out/${i}.mkv"
done