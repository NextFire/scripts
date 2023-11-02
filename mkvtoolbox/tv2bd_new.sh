#!/bin/bash
set -xe

FROM_DIR="$1"
TO_DIR="$2"

START_NB=${3:-1}
END_NB=${4:-$(($START_NB + $(ls "$FROM_DIR" | grep '.mkv$' | wc -l) - 1))}

KF_SCRIPT="$(dirname $0)/keyframes.py"

FIXED_DIR="$(dirname $0)/fixed"
mkdir -p "$FIXED_DIR"

for i in $(seq -f "%02g" $START_NB $END_NB)
do
  FROM_FILE=$(find "$FROM_DIR" -maxdepth 1 -regex ".*[^0-9S]$i[^0-9p][^/]*\.mkv")
  TO_FILE=$(find "$TO_DIR" -maxdepth 1 -regex ".*[^0-9S]$i[^0-9p][^/]*\.mkv")
  # SUB_FILE=$(find "$FROM_DIR" -maxdepth 1 -regex ".*[^0-9S]$i[^0-9p][^/]*\.ass")

  python3 "$KF_SCRIPT" --sushi --out-file "$FIXED_DIR/$i.from_kf.txt" "$FROM_FILE"; \
  rm "$FROM_FILE.ffindex" &
  python3 "$KF_SCRIPT" --sushi --out-file "$FIXED_DIR/$i.to_kf.txt" "$TO_FILE"; \
  rm "$TO_FILE.ffindex" &
  wait

  # Optionally add --script "$SUB_FILE" to the next line
  sushi --src "$FROM_FILE" --dst "$TO_FILE" \
  --src-keyframes "$FIXED_DIR/$i.from_kf.txt" --dst-keyframes "$FIXED_DIR/$i.to_kf.txt" \
  --max-kf-distance 5 -o "$FIXED_DIR/$i.ass"
  rm "$FIXED_DIR/$i.from_kf.txt" "$FIXED_DIR/$i.to_kf.txt"

  ffmpeg -y -i "$TO_FILE" -i "$FIXED_DIR/$i.ass" -i "$FROM_FILE" \
  -map 0:v -map 0:a -map 1 -map 2:t? -c copy \
  -disposition:s:0 default -metadata:s:s:0 language=fre \
  "$outd/$i.mkv"
done
