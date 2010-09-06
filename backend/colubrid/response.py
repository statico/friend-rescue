# -*- coding: utf-8 -*-
"""
    Colubrid Response
"""
from __future__ import generators
from colubrid.utils import HttpHeaders
from colubrid.const import HTTP_STATUS_CODES
from Cookie import SimpleCookie
from datetime import datetime
from time import gmtime


__all__ = ('HttpResponse',)


class HttpResponse(object):
    """
    The Response object is used to collect the data to be written
    back to the HTTP client.
    """

    def __init__(self, response=None, headers=None, status=200):
        if response is None:
            self.response = []
        elif isinstance(response, basestring):
            self.response = [response]
        else:
            self.response = response
        if headers is None:
            self.headers = HttpHeaders([])
        elif isinstance(headers, list):
            self.headers = HttpHeaders(headers)
        elif isinstance(headers, HttpHeaders):
            self.headers = headers
        else:
            raise TypeError('invalid header format')
        self.status = status
        self._cookies = None

    def __setitem__(self, name, value):
        self.headers[name] = value

    def __getitem__(self, name):
        self.headers.get(name)

    def __delitem__(self, name):
        del self.headers[name]

    def __contains__(self, name):
        return name in self.headers

    def __len__(self):
        if isinstance(self.response, list):
            length = 0
            for item in self.response:
                length += len(item)
            return length
        try:
            return len(self.response)
        except:
            return 0

    def write(self, d):
        if not isinstance(self.response, list):
            raise TypeError('read only or dynamic response object')
        elif isinstance(d, basestring):
            self.response.append(d)
        else:
            raise TypeError('str or unicode required')

    def set_cookie(self, key, value='', max_age=None, expires=None,
                   path='/', domain=None, secure=None):
        if self._cookies is None:
            self._cookies = SimpleCookie()
        self._cookies[key] = value
        if not max_age is None:
            self._cookies[key]['max-age'] = max_age
        if not expires is None:
            if isinstance(expires, basestring):
                self._cookies[key]['expires'] = expires
                expires = None
            elif isinstance(expires, datetime):
                expires = expires.utctimetuple()
            elif not isinstance(expires, (int, long)):
                expires = gmtime(expires)
            else:
                raise ValueError('datetime or integer required')
            if not expires is None:
                now = gmtime()
                month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul',
                         'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][now.tm_mon - 1]
                day = ['Monday', 'Tuesday', 'Wednesday', 'Thursday',
                       'Friday', 'Saturday', 'Sunday'][expires.tm_wday]
                date = '%02d-%s-%s' % (
                    now.tm_mday, month, str(now.tm_year)[-2:]
                )
                d = '%s, %s %02d:%02d:%02d GMT' % (day, date, now.tm_hour,
                                                   now.tm_min, now.tm_sec)
                self._cookies[key]['expires'] = d
        if not path is None:
            self._cookies[key]['path'] = path
        if not domain is None:
            self._cookies[key]['domain'] = domain
        if not secure is None:
            self._cookies[key]['secure'] = secure

    def delete_cookie(self, key):
        if self._cookies is None:
            self._cookies = SimpleCookie()
        if not key in self._cookies:
            self._cookies[key] = ''
        self._cookies[key]['max-age'] = 0

    def __call__(self, request):
        if not 'Content-Type' in self.headers:
            self.headers['Content-Type'] = 'text/html; charset=%s' % \
                                           str(request.charset)
        headers = self.headers.get()
        if not self._cookies is None:
            for morsel in self._cookies.values():
                headers.append(('Set-Cookie', morsel.output(header='')))
        status = '%d %s' % (self.status,
                            HTTP_STATUS_CODES.get(self.status, 'UNKNOWN'))
        request.start_response(status, headers)
        if self.response is None:
            yield ''
        elif isinstance(self.response, unicode):
            yield self.response.encode(request.charset)
        elif isinstance(self.response, str):
            yield self.response
        else:
            try:
                iterator = iter(self.response)
            except TypeError:
                raise TypeError('%r is not an valid response' % self.response)
            for line in iterator:
                if isinstance(line, unicode):
                    yield line.encode(request.charset)
                elif isinstance(line, str):
                    yield line
                else:
                    raise TypeError('%r is not string or unicode' % line)
