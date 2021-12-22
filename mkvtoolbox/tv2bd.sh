#!/bin/bash
set -x

based='tv2bd'
subsd="$based/subs"
outd="$based/out"

rm -rf "$based"
mkdir -p "$subsd" "$outd"

srcd="$1"
rawd="$2"
kfscript="$(dirname $0)/keyframes.py"

start=${3:-1}
end=${4:-$(($start + $(ls "$srcd" | grep '.mkv$' | wc -l) - 1))}

for i in $(seq -f "%02g" $start $end)
do
  srcf=$(find "$srcd" -maxdepth 1 -regex ".*[^0-9S]$i[^0-9p][^/]*\.mkv")
  rawf=$(find "$rawd" -maxdepth 1 -regex ".*[^0-9S]$i[^0-9p][^/]*\.mkv")
  subf=$(find "$srcd" -maxdepth 1 -regex ".*[^0-9S]$i[^0-9p][^/]*\.ass")

  python3 "$kfscript" --sushi --out-file "$subsd/$i.src.kf" "$srcf"; rm "$srcf.ffindex" &
  python3 "$kfscript" --sushi --out-file "$subsd/$i.dst.kf" "$rawf"; rm "$rawf.ffindex" &
  wait

  sushi --src "$srcf" --dst "$rawf" --script "$subf" \
  --src-keyframes "$subsd/$i.src.kf" --dst-keyframes "$subsd/$i.dst.kf" \
  --max-kf-distance 5 -o "$subsd/$i.ass"
  rm "$subsd/$i.src.kf" "$subsd/$i.dst.kf"

  ffmpeg -y -i "$rawf" -i "$subsd/$i.ass" -i "$srcf" \
  -map 0:v -map 0:a -map 1 -map 2:t? -c copy \
  -disposition:s:0 default -metadata:s:s:0 language=fre \
  "$outd/$i.mkv"
done
