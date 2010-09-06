# -*- coding: utf-8 -*-
"""
    Colubrid Exceptions
    ===================

    Since paste covers that too this is only a "redirection module".
    Because colubrid may change the error interface later it's
    better to use the mapped names instead of the paste.httpexceptions
    module.
"""

__all__ = ['PageNotFound', 'PageGone', 'AccessDenied', 'BadRequest',
           'RequestTimeout', 'ServerError', 'HttpRedirect', 'HttpFound',
           'HttpMoved']
           

ERROR_PAGE_TEMPLATE = """\
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<html>
 <head>
  <title>%(code)s %(title)s</title>
  <style type="text/css">
    body {
        font-family: sans-serif;
        margin: 2em;
        padding: 0;
    }
    a, h1 {
        color: #cc0000;
    }
    div.content {
        margin: 1em 3em 2em 2em;
    }
    address {
        border-top: 1px solid #ccc;
        padding: 0.3em;
    }
  </style>
 </head>
 <body>
<h1>%(title)s</h1>
<div class="content">%(msg)s</div>
<address>powered by colubrid %(version)s</address>
</body></html>
"""


class HttpException(Exception):
    """Base for HTTP exceptions. Not to be used directly."""
    code = None
    title = None
    msg = ''
    headers = None

    def get_error_page(self):
        from colubrid.utils import get_version
        from cgi import escape
        return ERROR_PAGE_TEMPLATE % {
            'code':     self.code,
            'title':    escape(self.title),
            'msg':      escape(self.msg),
            'version':  get_version()
        }

    def get_headers(self):
        if not self.headers:
            return []
        return self.headers[:]

    def __repr__(self):
        return '<%s %d>' % (self.__class__.__name__, self.code)


class HttpMove(HttpException):
    """Automatically add a "Location:" header to the result."""
    msg = 'The resource has been moved to %s.'
    
    def __init__(self, url):
        self.headers = [('Location', url)]
        if '%s' in self.msg:
            self.msg = self.msg % url


class PageNotFound(HttpException):
    """HTTP 404."""
    code = 404
    title = 'Not Found'
    msg = 'The resource could not be found.'


class PageGone(HttpException):
    """HTTP 410."""
    code = 410
    title = 'Gone'
    msg = ('This resource is no longer available. '
           'No forwarding address is given.')


class AccessDenied(HttpException):
    """HTTP 403."""
    code = 403
    title = 'Forbidden'
    msg = 'Access was denied to this resource.'


class BadRequest(HttpException):
    """HTTP 400."""
    code = 400
    title = 'Bad Request'
    msg = 'The server could not comply with the request since it is either '\
          'malformed or wtherwise incorrect.'


class RequestTimeout(HttpException):
    """HTTP 408."""
    code = 408
    title = 'Request Timeout'
    msg = 'There was a conflict when trying to complete your request.'


class ServerError(HttpException):
    """HTTP 500."""
    code = 500
    title = 'Internal Server Error'
    msg = 'The server has either erred or is inapable of performing '\
          'the requested operation.'


class HttpRedirect(HttpMove):
    """HTTP 307."""
    code = 307
    title = 'Temporary Redirect'


class HttpFound(HttpMove):
    """HTTP 302."""
    code = 302
    title = 'Found'
    msg = 'The resource was found at %s.'


class HttpMoved(HttpMove):
    """HTTP 301."""
    code = 301
    title = 'Moved Permanently'
