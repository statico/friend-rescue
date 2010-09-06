# -*- coding: utf-8 -*-
"""
    Colubrid Execute
    ================

    Since the 0.10 version of colubrid this is only a small helper module
    which uses paster to serve the application.
"""
from __future__ import generators
import sys
import os
from threading import Thread

__all__ = ('execute', 'run_test', 'stop_test')


class StaticExports(object):

    def __init__(self, app, exports):
        self.application = app
        self.exports = exports

    def serve_file(self, filename, start_response):
        from mimetypes import guess_type
        guessed_type = guess_type(filename)
        if guessed_type[0] is None:
            mime_type = 'text/plain'
        else:
            mime_type = guessed_type[0]
        start_response('200 OK', [('Content-Type', mime_type)])
        fp = file(filename, 'rb')
        try:
            result = fp.read()
        finally:
            fp.close()
        return iter([result])

    def __call__(self, environ, start_response):
        path_info = environ.get('PATH_INFO', '')
        for search_path, file_path in self.exports.iteritems():
            if not search_path.endswith('/'):
                search_path += '/'
            if path_info.startswith(search_path):
                real_path = os.path.join(file_path, path_info[len(search_path):])
                if os.path.exists(real_path) and os.path.isfile(real_path):
                    return self.serve_file(real_path, start_response)
        return self.application(environ, start_response)


def execute(app=None, debug=True, hostname='localhost', port=8080,
            reload=False, evalex=False):
    if app is None:
        frm = sys._getframe().f_back
        if not 'app' in frm.f_globals:
            raise RuntimeError('no application found')
        app = frm.f_globals['app']
    if debug:
        from colubrid.debug import DebuggedApplication
        app = DebuggedApplication(app, evalex)

    try:
        from paste import httpserver
        run = lambda: httpserver.serve(app, host=hostname, port=str(port))
    except ImportError:
        try:
            from BaseWSGIServer import WSGIServer
            run = WSGIServer(app, hostname, port).serve_forever
        except ImportError:
            try:
                from wsgiref.simple_server import make_server
                run = make_server(hostname, port, app).serve_forever
            except ImportError:
                run = None
    if run is None:
        raise RuntimeError('no standalone wsgi server found')
    if reload:
        from colubrid import reloader
        reloader.main(run)
    else:
        run()
