#!/bin/bash -xe

SRC_DIR="$1"
RAW_DIR="$2"
OUT_DIR="$3"

NB_FILES=$(ls "$SRC_DIR" | wc -l)

OFFSETS=(. -1 -1 -1 -1 -1 -1)

for i in $(seq -f "%02g" $NB_FILES)
do
  SRC=$(find "$SRC_DIR" -regex ".*[^0-9S]${i}[^0-9].*")
  RAW=$(find "$RAW_DIR" -regex ".*[^0-9S]${i}[^0-9].*")
  OUT=$OUT_DIR/$(basename "$RAW" | sed 's/\(.*\)\.\(.*\)/\1 (1).\2/')
  ffmpeg -y -i "$RAW" -itsoffset ${OFFSETS[${i#0}]} -i "$SRC" -map 0:v -map 0:a -map 1:s -map 1:t:? -c copy "$OUT"
done
