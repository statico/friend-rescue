#!/usr/bin/env python
#
# Copyright 2008 Ian Langworth

import logging
import md5
import re
import simplejson
import time
import urllib
import webob

from google.appengine.api import memcache
from google.appengine.api import urlfetch


class Error(Exception):
  """General base class for errors in this module."""


class ApiError(Error):
  """Raised when an error occurs during an API call."""



class Middleware(object):

  def __init__(self, app, api):
    self.app = app
    self.api = api

  def __call__(self, environ, start_response):
    request = webob.Request(environ)
    self.fb = self.api.GetSession(request.params)
    return self.app(environ, start_response)


class BaseApi(object):

  def __init__(self,
               api_key=None,
               api_version='1.0',
               api_url='http://api.facebook.com/restserver.php',
               secret=None):
    self.api_key = api_key
    self.api_version = api_version
    self.api_url = api_url
    self.secret = secret

  def _Post(self, args={}):
    raise NotImplementedError

  def Call(self, method, **kwargs):
    params = dict(kwargs,
                  method=method,
                  api_key=self.api_key,
                  v=self.api_version,
                  format='JSON')

    # Memcache key doesn't use the call_id or sig because those change.
    cache_key = urllib.urlencode(params)
    try:
      content = memcache.get(cache_key)
    except ValueError, e:
      logging.debug('memcache.get failed: %s', e)
      content = None
    if content is not None:
      logging.debug('Cache hit for method %s', method)
    else:
      logging.debug('Cache miss for method %s', method)

      params['call_id'] = int(time.time() * 1e6)

      md5hash = md5.new()
      for key, value in sorted(params.items()):
        md5hash.update(key)
        md5hash.update("=")
        md5hash.update(str(value))
      md5hash.update(self.secret)
      params['sig'] = md5hash.hexdigest()

      response = self._Post(params)

      content = response.content
      try:
        memcache.set(cache_key, content, 60 * 60 * 24)
      except ValueError, e:
        logging.debug('memcache.set failed: %s', e)

    data = simplejson.loads(content)

    try:
      raise ApiError(data['fb_error']['msg'])
    except (LookupError, TypeError):
      try:
        raise ApiError('Error %(error_code)d: %(error_msg)s' % data)
      except (LookupError, TypeError):
        pass

    return data

  def ValidateParams(self, params):
    signature = params.get('fb_sig')
    if signature is None:
      return None

    prefix = "fb_sig_"
    preflen = len(prefix)
    unsigned = {}
    signed_tuples = []
    for name, value in params.items():
        if name.startswith(prefix):
            signed_tuples.append((name[preflen:], value))
        else:
            unsigned[name] = value
    signed_tuples.sort()

    md5hash = md5.new()
    for key, value in signed_tuples:
        md5hash.update(key)
        md5hash.update("=")
        md5hash.update(value)
    md5hash.update(self.secret)

    if md5hash.hexdigest() == signature:
      signed = dict(signed_tuples)
      # Order here is important. We want to make sure that the unsigned
      # parameters don't override the signed parameters.
      return dict(unsigned, **signed)
    else:
      logging.error('Facebook Sig = %s', signature)
      logging.error('Our Sig = %s', md5hash.hexdigest())
      logging.error('md5hash signature failed')
      return None

  def GetSession(self, params):
    validated = self.ValidateParams(params)
    return Session(self, validated)

  def RestoreSession(self, session_key):
    return Session(self, {'session_key': session_key})


class RestApi(BaseApi):

  def _Post(self, args={}):
    argstr = urllib.urlencode(args)
    logging.debug('API Request: %s?%s', self.api_url, argstr)
    response = urlfetch.fetch(self.api_url, payload=argstr,
        method=urlfetch.POST,
        headers={'Content-type': 'application/x-www-form-urlencoded'})
    if response.content_was_truncated:
      logging.error('API response content was truncated.')
    logging.debug('API Response: %s - %s', response.status_code,
        response.content)
    return response


class Session(object):

  def __init__(self, api, params):
    self.api = api
    self.params = params or {}

  def Call(self, method, **kwargs):
    session_key = self.params.get('session_key')
    return self.api.Call(method, session_key=session_key, **kwargs)

  def IsInCanvas(self):
    return int(self.params.get('in_canvas', 0))

  def HasSession(self):
    return self.params.has_key('session_key')

  def HasUserAddedApp(self):
    return int(self.params.get('added', 0))

  def GetUID(self):
    try:
      return int(self.params['user'])
    except KeyError:
      if self.GetSessionKey() is not None:
        return int(re.sub(r'^.*-', '', self.GetSessionKey()))
      else:
        return None

  def GetSessionKey(self):
    return self.params.get('session_key')

  def Redirect(self, url):
    if self.IsInCanvas():
      return '<fb:redirect url="%s"/>' % url
    else:
      return '''
        <script type="text/javascript">
        top.location.href = "%s";
        </script>
        ''' % url

