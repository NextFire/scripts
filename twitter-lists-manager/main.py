import os
import webbrowser

import tweepy

from keys import (ACCESS_TOKEN, ACCESS_TOKEN_SECRET, CONSUMER_KEY,
                  CONSUMER_SECRET)

client = tweepy.Client(consumer_key=CONSUMER_KEY,
                       consumer_secret=CONSUMER_SECRET,
                       access_token=ACCESS_TOKEN,
                       access_token_secret=ACCESS_TOKEN_SECRET)
self_id = ACCESS_TOKEN.partition('-')[0]


def get_lists():
    for resp in tweepy.Paginator(client.get_owned_lists,
                                 self_id,
                                 user_auth=True):
        for l in resp.data:
            yield l


def get_lists_members(twitter_lists):
    ids = set()
    for l in twitter_lists:
        for resp in tweepy.Paginator(client.get_list_members,
                                     l.id,
                                     user_auth=True):
            if resp.data is not None:
                ids.update(u.id for u in resp.data)
    return ids


def get_following():
    for resp in tweepy.Paginator(client.get_users_following,
                                 self_id,
                                 user_auth=True,
                                 max_results=1000):
        for f in resp.data:
            yield f


def main():
    twitter_lists = list(get_lists())
    twitter_list_members = get_lists_members(twitter_lists)

    twitter_lists.sort(key=lambda l: l.name.casefold())
    twitter_lists = [None] + twitter_lists

    lists_print = '    '.join([f"{i}:{l}" for i, l in enumerate(twitter_lists)])

    for f in get_following():
        if f.id in twitter_list_members:
            continue

        user = client.get_user(id=f.id,
                               user_auth=True,
                               user_fields=['description', 'public_metrics'])

        os.system('cls' if os.name == 'nt' else 'clear')
        webbrowser.open(f"https://twitter.com/{user.data.username}/media")

        print(
            f"{user.data.name}\n"
            f"@{user.data.username} (https://twitter.com/{user.data.username})\n"
            f"{user.data.public_metrics['followers_count']} followers\n"
            f"\n"
            f"{user.data.description}")
        print('-----------------')
        print('Twitter lists:')
        print(lists_print)
        print('-----------------')
        nblist = int(input(f"Move to list [0-{len(twitter_lists)-1}]: "))

        chosen_list = twitter_lists[nblist]
        if chosen_list is not None:
            client.add_list_member(chosen_list.id, user.data.id)
            # client.unfollow_user(user.data.id)


if __name__ == '__main__':
    main()
