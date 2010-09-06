#!/usr/bin/env python
#
# Copyright 2008 Ian Langworth

import models

print 'Content-type: text/plain'
print

def section(name):
  print
  print '================================================'
  print name.upper()
  print '================================================'
  print

section('most recent actions')
for row in models.Action.gql('ORDER BY when DESC LIMIT 50'):
  print row


