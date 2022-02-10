from main import *

following = [f.id for f in get_following()]

for l in [1479850859961933824, 1479852006030430220]:
    for resp in tweepy.Paginator(client.get_list_members, l, user_auth=True):
        for u in resp.data:
            if u.id in following:
                client.unfollow(u.id)

ids = set()
for l in [1479852127384133635, 1479851547282530308]:
    for resp in tweepy.Paginator(client.get_list_members, l, user_auth=True):
        ids.update(u.id for u in resp.data)

for f in get_following():
    if f.id not in ids:
        client.unfollow(f.id)
