#!/bin/bash
set -x

srcd="$1"
rawd="$2"
kfscript="$(dirname $0)/keyframes.py"

based='tv2bd'
subsd="$based/subs"
outd="$based/out"
mkdir -p "$based" "$subsd" "$outd"

nb=$(ls "$srcd" | wc -l)

for i in $(seq -f "%02g" $nb)
do
  srcf=$(find "$srcd" -maxdepth 1 -regex ".*[^0-9S]$i[^0-9][^/]*\.mkv")
  rawf=$(find "$rawd" -maxdepth 1 -regex ".*[^0-9S]$i[^0-9][^/]*\.mkv")
  subf=$(find "$srcd" -maxdepth 1 -regex ".*[^0-9S]$i[^0-9][^/]*\.ass")

  python3 "$kfscript" --sushi --out-file "$subsd/$i.src.kf" "$srcf"
  python3 "$kfscript" --sushi --out-file "$subsd/$i.dst.kf" "$rawf"
  rm "$srcf.ffindex" "$rawf.ffindex"

  if [ -z "$subf" ];
  then
    sushi --src "$srcf" --dst "$rawf" \
    --src-keyframes "$subsd/$i.src.kf" --dst-keyframes "$subsd/$i.dst.kf" \
    --chapters none --max-kf-distance 5 -o "$subsd/$i.ass"
  else
    sushi --src "$srcf" --dst "$rawf" --script "$subf" \
    --src-keyframes "$subsd/$i.src.kf" --dst-keyframes "$subsd/$i.dst.kf" \
    --chapters none --max-kf-distance 5 -o "$subsd/$i.ass"
  fi

  ffmpeg -y -i "$rawf" -i "$subsd/$i.ass" -i "$srcf" \
  -map 0:v -map 0:a -map 1 -map 2:t? -c copy \
  -disposition:s:0 default -metadata:s:s:0 language=fre \
  "$outd/$i.mkv"
done
