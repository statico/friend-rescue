#!/usr/bin/env python
#
# Copyright 2008 Ian Langworth

"""Simple routines for signing and verifying data for use with RPC."""

import simplejson
import md5


def Sign(key, data):
  m = md5.new()
  m.update(data)
  m.update(key)
  return m.hexdigest() + data


def UnSign(key, raw):
  if raw is None:
    return None
  given, data = raw[0:32], raw[32:]
  if len(given) == 0 or len(data) == 0:
    return None

  m = md5.new()
  m.update(data)
  m.update(key)
  if given == m.hexdigest():
    return data
  else:
    return None


def Encode(key, obj):
  try:
    data = simplejson.dumps(obj, ensure_ascii=False)
  except ValueError:
    return None
  return Sign(key, data)


def Decode(key, raw):
  data = UnSign(key, raw)
  if data is None:
    return None

  try:
    return simplejson.loads(data)
  except ValueError:
    return None


if __name__ == '__main__':
  key = 'foo'
  obj = [{'bacon': 'eggs'}, 'ham']

  raw = Encode(key, obj)
  assert type(raw) == str
  assert raw != simplejson.dumps(obj)
  assert raw != key

  obj2 = Decode(key, raw)
  assert obj2 == obj

  copy = 'x' + raw[1:] # Assuming 'x' isn't char 0 of the md5sum
  assert Decode(key, copy) is None

  copy = 'x' + raw[:1]
  assert Decode(key, copy) is None

  assert Decode(key, 'afljsfkladlsfjk') is None

  assert Decode(key, Encode(key, None)) == None
  assert Decode(key, Encode(key, [])) == []
  assert Decode(key, Encode(key, [1, 2, 3])) == [1, 2, 3]
  assert Decode(key, Encode(key, {'foo': 'bar'})) == {'foo': 'bar'}
  assert Decode(key, Encode(key, 'string')) == 'string'
  assert Decode(key, Encode(key, 1234)) == 1234

  import base64
  encoded = Encode(key, base64.b64encode('\x00\x80\xff'))
  decoded = base64.b64decode(Decode(key, encoded))
  assert decoded == '\x00\x80\xff'

  print 'all tests ok'
