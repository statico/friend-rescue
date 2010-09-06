#!/usr/bin/env python
#
# Copyright 2008 Ian Langworth

import datetime

from google.appengine.ext import db


FB = 'facebook'
OS = 'opensocial'


class HighScore(db.Model):
  when = db.DateTimeProperty(required=True, auto_now_add=True)
  uid = db.IntegerProperty(required=True)
  network = db.StringProperty(required=True)
  score = db.IntegerProperty(required=True)

  @classmethod
  def GetScoreForUID(cls, uid, network):
    result = HighScore.gql('WHERE uid = :uid AND network = :network',
        uid=uid, network=network).get()
    if result:
      return result.score
    else:
      return None


class Action(db.Model):
  when = db.DateTimeProperty(required=True, auto_now_add=True)
  uid = db.IntegerProperty(required=True)
  network = db.StringProperty(required=True)
  action = db.StringProperty(required=True)
  intvalue = db.IntegerProperty()
  stringvalue = db.StringProperty()

  def __str__(self):
    fields = 'when uid network action intvalue stringvalue'
    return '\t'.join([str(getattr(self, x)) for x in fields.split()])

  @classmethod
  def NumNotificationsInLastDay(cls, uid, network):
    yesterday = datetime.datetime.now() - datetime.timedelta(1)
    return Action.gql('WHERE action = :action AND uid = :uid '
        'AND network = :network AND when > :yesterday',
        action='notify', uid=uid, network=network, yesterday=yesterday).count()
