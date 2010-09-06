#!/usr/bin/env python
#
# Copyright 2008 Ian Langworth

import base64
import facebook
import logging
import models
import os
import random
import re
import signed_serializer
import urllib

from google.appengine.api import urlfetch
from google.appengine.api import memcache
from google.appengine.ext import db
from google.appengine.ext import webapp
from google.appengine.ext.webapp import template
from google.appengine.ext.webapp.util import run_wsgi_app


devmode = os.environ.get('SERVER_SOFTWARE', '').startswith('Devel')

if devmode:
  # Local App Development
  API_KEY = '33f757200284ca38867e8695d5ab850f'
  SECRET_KEY = '740be438066fda7c6a642322855ba06d'
else:
  # Friend Rescue
  API_KEY = 'dc2381768401ab97116e1c4c08f4cb38'
  SECRET_KEY = 'e7839ccf1ecf926ffa2513753c7933be'

ADD_APP_URL = 'http://www.facebook.com/add.php?api_key=' + API_KEY
MAIN_APP_URL = 'http://apps.facebook.com/friendrescue/'
ABOUT_APP_URL = 'http://www.facebook.com/apps/application.php?id=28379717283'
RPC_KEY = '1111111128271'

MAX_NOTIFICATIONS_PER_USER_PER_DAY = 10

api = facebook.RestApi(api_key=API_KEY, secret=SECRET_KEY)


def SendNotification(fb=None, from_uid=None, to_uid=None, fbml=None):
  count = models.Action.NumNotificationsInLastDay(from_uid, models.FB)
  logging.debug('UID %s has sent %s notifications in the last 24 hours', from_uid, count)
  if count < MAX_NOTIFICATIONS_PER_USER_PER_DAY:
    models.Action(uid=from_uid,
                  network=models.FB,
                  action='notify',
                  intvalue=to_uid,
                  ).put()
    fb.Call('notifications.send', to_ids=[to_uid], notification=fbml)
    logging.debug('Notification sent from UID %s to UID %s: %s', from_uid,
        to_uid, fbml)


def RPC(func):
  def wrapper(self):
    raw = self.request.get('data') or self.request.body
    raw = urllib.unquote(raw)
    raw = re.sub(r'=$', '', raw)

    logging.debug('Request data: %s', raw)
    if not raw:
      logging.warn('No data received')
      return

    obj = signed_serializer.Decode(RPC_KEY, raw)
    if not obj:
      logging.warn('Decoding failed for: %s', raw)
      return

    session_key = obj.get('session_key')
    if not session_key:
      logging.warn('Call to method had no session_key')
      return

    fb = api.RestoreSession(session_key)
    if not fb:
      logging.warn('No valid session for session_key %s', session_key)
      return

    self.fb = fb
    self.rpc = obj

    try:
      result = func(self)
    except facebook.ApiError, e:
      logging.error('Facebook error for uid=%d: %s', fb.GetUID(), e)
      return

    if result is None:
      logging.debug('RPC returned none')
      return

    out = signed_serializer.Encode(RPC_KEY, result)
    self.response.out.write(out)

  return wrapper


class GetFriends(webapp.RequestHandler):
  @RPC
  def post(self):
    COUNT_APP_USERS = 20
    COUNT_OTHER_FRIENDS = 20

    friends_to_fetch = []

    # Get all the app users and sort them, then add the top N friends to a list
    # whose info we'll return.
    app_user_uids = set(self.fb.Call('friends.getAppUsers'))
    uids = [(uid, models.HighScore.GetScoreForUID(uid, models.FB), True)
            for uid in app_user_uids]
    uids.sort(reverse=True)
    friends_to_fetch.extend(uids[:COUNT_APP_USERS])
    logging.info('Collected %d app users', len(friends_to_fetch))

    # Get a the rest of the user's friends, pick N randomly and also add them to
    # the list to return.
    other_friend_uids = set(self.fb.Call('friends.get')) - app_user_uids
    for uid in random.sample(other_friend_uids, COUNT_OTHER_FRIENDS):
      friends_to_fetch.append((uid, None, False))
    logging.info('Collected %d friends total', len(friends_to_fetch))

    # Build the results which to return.
    friends = []
    for uid, high_score, has_added_app in friends_to_fetch:
      result = self.fb.Call('users.getInfo', uids=uid,
                            fields='first_name,sex,pic_square,profile_url')
      info = result[0]
      try:
        friends.append({'uid': uid,
                        'name': info['first_name'],
                        'sex': info['sex'],
                        'highScore': high_score or 0,
                        'imageUrl': info['pic_square'],
                        'profileUrl': info['profile_url'],
                        'hasAddedApp': has_added_app,
                        })
      except KeyError, e:
        logging.error('Problem with getInfo for uid %d: %s', uid, e)

    return friends


class GetHighScore(webapp.RequestHandler):
  @RPC
  def post(self):
    uid = self.fb.GetUID()
    score = models.HighScore.GetScoreForUID(uid, models.FB)
    if score is None:
      return 0
    else:
      return score


class RecordFriendAsRescued(webapp.RequestHandler):
  @RPC
  def post(self):
    uid = self.fb.GetUID()
    models.Action(uid=uid,
                  network=models.FB,
                  action='rescued',
                  intvalue=self.rpc.get('uid'),
                  ).put()
    SendNotification(fb=self.fb, from_uid=uid, to_uid=self.rpc.get('uid'),
        fbml="""
        <fb:name uid="%s"/> rescued you from the cold depths of space in
        <a href="%s">Friend Rescue</a>!
        """ % (uid, MAIN_APP_URL))


class RecordFriendAsDestroyed(webapp.RequestHandler):
  @RPC
  def post(self):
    uid = self.fb.GetUID()
    models.Action(uid=uid,
                  network=models.FB,
                  action='destroyed',
                  intvalue=self.rpc.get('uid'),
                  ).put()
    SendNotification(fb=self.fb, from_uid=uid, to_uid=self.rpc.get('uid'),
        fbml="""
        <fb:name uid="%s"/> vaporized you in
        <a href="%s">Friend Rescue</a>!
        """ % (uid, MAIN_APP_URL))


class RecordFriendAsDefeated(webapp.RequestHandler):
  @RPC
  def post(self):
    uid = self.fb.GetUID()
    models.Action(uid=uid,
                  network=models.FB,
                  action='defeated',
                  intvalue=self.rpc.get('uid'),
                  ).put()


class RecordGameBegin(webapp.RequestHandler):
  @RPC
  def post(self):
    uid = self.fb.GetUID()
    models.Action(uid=uid,
                  network=models.FB,
                  action='gamebegin',
                  ).put()


class RecordGameEnd(webapp.RequestHandler):
  @RPC
  def post(self):
    uid = self.fb.GetUID()
    score = self.rpc.get('score')
    models.Action(uid=uid,
                  network=models.FB,
                  action='levelreached',
                  intvalue=self.rpc.get('level'),
                  ).put()
    models.Action(uid=uid,
                  network=models.FB,
                  action='gamescore',
                  intvalue=score,
                  ).put()
    models.Action(uid=uid,
                  network=models.FB,
                  action='gameduration',
                  intvalue=self.rpc.get('duration'),
                  ).put()

    hs = models.HighScore.gql('WHERE uid = :uid AND network = :network',
                              uid=uid, network=models.FB).get()
    if (not hs) or (hs and hs.score < score):
      if hs: hs.delete()
      models.HighScore(uid=int(uid), network=models.FB, score=score).put()
      models.Action(uid=uid,
                    network=models.FB,
                    action='highscore',
                    intvalue=score,
                    ).put()


class MainPage(webapp.RequestHandler):
  def get(self):
    fb = api.GetSession(self.request.GET)

    if fb.GetUID() is not None:
      models.Action(uid=fb.GetUID(),
                    network=models.FB,
                    action='loadgame',
                    stringvalue=self.request.headers.get('user-agent'),
                    ).put()

    context = {'query_string': self.request.query_string, # This is safe.
               'has_session': fb.HasSession(),
               'add_app_url': ADD_APP_URL,
               'about_app_url': ABOUT_APP_URL,
               'version': os.getcwd().split('/')[-1],
               'devmode': devmode}
    self.response.out.write(template.render('fb.html', context))


urlmap = [('/fb/', MainPage),
          ('/fb/rpc/GetFriends', GetFriends),
          ('/fb/rpc/GetHighScore', GetHighScore),
          ('/fb/rpc/RecordFriendAsRescued', RecordFriendAsRescued),
          ('/fb/rpc/RecordFriendAsDestroyed', RecordFriendAsDestroyed),
          ('/fb/rpc/RecordFriendAsDefeated', RecordFriendAsDefeated),
          ('/fb/rpc/RecordGameBegin', RecordGameBegin),
          ('/fb/rpc/RecordGameEnd', RecordGameEnd),
          ]
application = webapp.WSGIApplication(urlmap)


def main():
  run_wsgi_app(application)


if __name__ == '__main__':
  main()
