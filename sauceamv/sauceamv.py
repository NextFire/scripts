#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys
import time
from datetime import timedelta

import requests

TRACE_API = 'https://api.trace.moe/search'
AL_API = 'https://graphql.anilist.co'

al_cache = {}


def get_trace(path: str):
    resp = requests.post(
        TRACE_API, files={'image': open(path, 'rb')})

    if resp.status_code == 429:
        reset_at = resp.headers.get('x-ratelimit-reset')
        print(
            f'Reached rate limit for trace.moe: {reset_at}', file=sys.stderr)
        time.sleep(int(reset_at) - time.time())
        return get_trace(path)

    resp_json = resp.json()

    if resp_json['error'] != '':
        raise RuntimeError(str(resp_json['error']))

    return resp_json['result'][0]


def get_al(id: int):
    if id not in al_cache.keys():
        query = '''
                query ($id: Int) {
                    Media(id: $id, type: ANIME) {
                        title {
                            romaji
                        }
                        siteUrl
                    }
                }
                '''
        variables = {'id': id}
        resp = requests.post(
            AL_API, json={'query': query, 'variables': variables})

        if reset_at := resp.headers.get('X-RateLimit-Reset'):
            print(
                f'Reached rate limit for AL: {reset_at}', file=sys.stderr)
            time.sleep(int(reset_at) - time.time())
            return get_al(id)

        resp_json = resp.json()

        if 'errors' in resp_json:
            raise RuntimeError(str(resp_json['errors']))

        al_cache[id] = resp_json['data']['Media']

    return al_cache[id]


# Parsing
parser = argparse.ArgumentParser()
parser.add_argument('FILE', type=str, help='Video file to analyze')
args = parser.parse_args()


# ffmpeg I-frames
try:
    os.mkdir(f'{args.FILE}_frames')
except OSError as error:
    print(error, file=sys.stderr)
    print(f'Skipping I-frames generation', file=sys.stderr)
else:
    # pylint: disable=anomalous-backslash-in-string
    subprocess.run(['ffmpeg', '-i', args.FILE, '-vf', "select='eq(pict_type\,I)'",
                    '-vsync', '0', '-frame_pts', '1', '-r', '1000', f'{args.FILE}_frames/%08d.jpg'])


# Analysis
with os.scandir(f'{args.FILE}_frames') as it:
    frames = []
    for entry in it:
        if entry.name.endswith('.jpg'):
            frames.append({
                'time': str(timedelta(milliseconds=int(entry.name[:8]))),
                'file': f'{args.FILE}_frames/{entry.name}'
            })
for i in range(len(frames)):
    print('[' + frames[i]['time']
          + ' -> '
          + (frames[i+1]['time'] if i < len(frames) - 1 else 'end') + ']')
    # trace.moe
    trace = get_trace(frames[i]['file'])
    # anilist
    al = get_al(trace['anilist'])
    print(al['title']['romaji'])
    print(al['siteUrl'])
    print(f"Episode {trace['episode']} @ {timedelta(seconds=trace['from'])}")
    print()
