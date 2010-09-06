# -*- coding: utf-8 -*-
"""
    Colubrid Request Object
    =======================
"""

from __future__ import generators
from colubrid.utils import MultiDict, MergedMultiDict, FieldStorage,\
                           get_full_url
from colubrid.response import HttpResponse

import posixpath
import cgi
import email
from urllib import quote
from email.Message import Message as MessageType
from cStringIO import StringIO
from Cookie import SimpleCookie


__all__ = ('Request', 'ResponseRequest')


class Request(object):
    """
    The central Request object. It stores all data coming from
    the HTTP client.
    """

    def __init__(self, environ, start_response, charset='utf-8'):
        self.charset = charset
        self.start_response = start_response
        self.environ = environ
        self.environ['REQUEST_URI'] = get_full_url(self.environ)

        # copy a reference to the request object
        # into the environ so wsgi middlewares
        # can communicate with it.
        environ['colubrid.request'] = self

        # get absolute path to script
        root = self.environ.get('SCRIPT_NAME', '/')
        if not root or not root.startswith('/'):
            root = '/' + root
        self.environ['SCRIPT_ROOT'] = root

        # get the full application request
        url = ''.join([
            quote(self.environ['SCRIPT_NAME']),
            quote(self.environ.get('PATH_INFO', ''))
        ])
        if not url.startswith('/'):
            url = '/' + url
        self.environ['APPLICATION_REQUEST'] = url

    def read(self, *args):
        if not hasattr(self, '_buffered_stream'):
            self._buffered_stream = StringIO(self.data)
        return self._buffered_stream.read(*args)

    def readline(self, *args):
        if not hasattr(self, '_buffered_stream'):
            self._buffered_stream = StringIO(self.data)
        return self._buffered_stream.readline(*args)

    def readlines(self, *args):
        while True:
            line = self.readline(*args)
            if not line:
                raise StopIteration()
            yield line

    def _load_post_data(self):
        self._data = ''
        if self.environ['REQUEST_METHOD'] == 'POST':
            maxlen = int(self.environ['CONTENT_LENGTH'])
            self._data = self.environ['wsgi.input'].read(maxlen)
            if self.environ.get('CONTENT_TYPE', '').startswith('multipart'):
                lines = ['Content-Type: %s' %
                         self.environ.get('CONTENT_TYPE', '')]
                for key, value in self.environ.items():
                    if key.startswith('HTTP_'):
                        lines.append('%s: %s' % (key, value))
                raw = '\r\n'.join(lines) + '\r\n\r\n' + self._data
                msg = email.message_from_string(raw)
                self._post = MultiDict()
                self._files = MultiDict()
                for sub in msg.get_payload():
                    if not isinstance(sub, MessageType):
                        continue
                    name_dict = cgi.parse_header(sub['Content-Disposition'])[1]
                    if 'filename' in name_dict:
                        payload = sub.get_payload()
                        filename = name_dict['filename']
                        if isinstance(payload, list) or not filename.strip():
                            continue
                        filename = name_dict['filename']
                        #XXX: fixes stupid ie bug but can cause problems
                        filename = filename[filename.rfind('\\') + 1:]
                        if 'Content-Type' in sub:
                            content_type = sub['Content-Type']
                        else:
                            content_type = None
                        s = FieldStorage(name_dict['name'], filename,
                                         content_type, payload)
                        self._files.appendlist(name_dict['name'], s)
                    else:
                        value = sub.get_payload()
                        if not self.charset is None:
                            value = value.decode(self.charset, 'ignore')
                        self._post.appendlist(name_dict['name'], value)
            else:
                d = cgi.parse_qs(self._data, True)
                if not self.charset is None:
                    for key, value in d.iteritems():
                        d[key] = [i.decode(self.charset, 'ignore')
                                  for i in value]
                self._post = MultiDict(d)
                self._files = MultiDict()
        else:
            self._post = MultiDict()
            self._files = MultiDict()

    def args(self):
        if not hasattr(self, '_get'):
            query = cgi.parse_qs(self.environ.get('QUERY_STRING', ''), True)
            if not self.charset is None:
                for key, value in query.iteritems():
                    query[key] = [i.decode(self.charset, 'ignore')
                                  for i in value]
            self._get = MultiDict(query)
        return self._get

    def form(self):
        if not hasattr(self, '_post'):
            self._load_post_data()
        return self._post

    def values(self):
        if not hasattr(self, '_values'):
            self._values = MergedMultiDict(self.args, self.form)
        return self._values

    def files(self):
        if not hasattr(self, '_files'):
            self._load_post_data()
        return self._files

    def cookies(self):
        if not hasattr(self, '_cookie'):
            self._cookie = SimpleCookie()
            self._cookie.load(self.environ.get('HTTP_COOKIE', ''))
        return self._cookie

    def data(self):
        if not hasattr(self, '_data'):
            self._load_post_data()
        return self._data

    args = property(args, doc='url paramters')
    form = property(form, doc='form data')
    files = property(files, doc='submitted files')
    values = property(values, doc='url parameters and form data')
    cookies = property(cookies, doc='cookies')
    data = property(data, doc='raw value of input stream')


class ResponseRequest(Request, HttpResponse):
    """
    A Request that's a Response too. This way users can call
    request.write() etc.
    """

    def __init__(self, environ, start_response, charset='utf-8'):
        Request.__init__(self, environ, start_response, charset)
        HttpResponse.__init__(self, [], [], 200)


class RoutesRequest(Request):

    def __init__(self, app, environ, start_response, charset='utf-8'):
        super(RoutesRequest, self).__init__(environ, start_response, charset)
        self.app = app

    def link_to(self, __controller__, **kwargs):
        controller = self.app._controller_map.get(__controller__)
        root = self.environ['SCRIPT_ROOT']
        link = self.app._routes_map.generate(controller, **kwargs)
        if link is None:
            return root
        return posixpath.join(root, link[1:])
