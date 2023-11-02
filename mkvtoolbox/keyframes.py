import argparse
import pathlib

import vapoursynth as vs
from vapoursynth import core

parser = argparse.ArgumentParser()
parser.add_argument('--use-scxvid', action='store_true', help="use Scxvid instead of WWXD to detect scene changes")
parser.add_argument('--use-slices', action='store_true', help="when using Scxvid, speeds things up at the cost of differences in scene detection")
parser.add_argument('--sushi', action='store_true', help="sushi compatible (pseudo-XviD 2pass stat file) format")
parser.add_argument('--out-file', help="the file to write scene changes to (Aegisub format); defaults to 'keyframes.txt' in the same directory as the input video file")
parser.add_argument('clip', help="the input video file")
args = parser.parse_args()

out_path = args.out_file or str(pathlib.Path(args.clip).parent / "keyframes.txt")
use_scxvid = args.use_scxvid

clip = core.ffms2.Source(source=args.clip)
clip = core.resize.Bilinear(clip, 640, 360, format=vs.YUV420P8)  # speed up the analysis by resizing first
clip = core.scxvid.Scxvid(clip, use_slices=args.use_slices) if use_scxvid else core.wwxd.WWXD(clip)

out_txt = []
if args.sushi:
    out_txt.append("# XviD 2pass stat file\n\n")
else:
    out_txt.append("# keyframe format v1\nfps 0")

for i in range(clip.num_frames):
    props = clip.get_frame(i).props
    scenechange = props._SceneChangePrev if use_scxvid else props.Scenechange
    if args.sushi:
        out_txt.append("i" if scenechange else "b")
    elif scenechange:
        out_txt.append(str(i))
    if i % 1000 == 0:
        print(i)

out_txt.append("") # trailing newline just in case

with open(out_path, 'w') as f:
    f.write("\n".join(out_txt))
