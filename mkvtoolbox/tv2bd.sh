#!/bin/bash

cd "$(dirname "$0")"
mkdir 1subs 3out

for i in $(seq -f "%02g" 1 $(ls 2raw | wc -l))
do
  src=$(find 1source -regex ".*[^0-9S]${i}[^0-9].*")
  dst=$(find 2raw -regex ".*[^0-9S]${i}[^0-9].*")

  python3 keyframes.py --sushi --out-file "1subs/${i}.src.txt" "$src"
  python3 keyframes.py --sushi --out-file "1subs/${i}.dst.txt" "$dst"
  rm "$src.ffindex" "$dst.ffindex"

  sushi --src "$src" --dst "$dst" --src-keyframes "1subs/${i}.src.txt" --dst-keyframes "1subs/${i}.dst.txt" \
  --chapters none --max-kf-distance 5 -o "1subs/${i}.ass"

  ffmpeg -n -i "$dst" -i "1subs/${i}.ass" -i "$src" \
  -map 0 -map 1 -map 2:t? -c copy -disposition:s:0 default -metadata:s:s:0 language=fre "3out/${i}.mkv"
done