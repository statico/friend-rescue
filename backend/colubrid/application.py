# -*- coding: utf-8 -*-
"""
    Colubrid Base Applications
    ==========================

    This file provides a list of colubrid application. Each of them inherits
    form BaseApplication and implements a full WSGI compatible web application.
    
    If you like to add your own you _have_ to inherit from BaseApplication or
    the Request object wont work properly.

    Since colubrid 0.10 you don't have to use those base application objects.
    If you're looking for an example check out the `customapp.py`
    application in the example folder.
"""

from __future__ import generators
from colubrid.request import Request, ResponseRequest, RoutesRequest
from colubrid.response import HttpResponse
from colubrid.utils import fix_slash
from colubrid.exceptions import HttpException, PageNotFound
import re

__all__ = ('BaseApplication', 'RegexApplication', 'ResolveRegexApplication',
           'PathApplication', 'ObjectApplication', 'WebpyApplication',
           'RoutesApplication')


class RegexCompilerClass(type):
    """
    Metaclass that automatically compiles regular expressions in
    the 'urls' attribute.
    """

    def __new__(cls, name, bases, dct):
        result = type.__new__(cls, name, bases, dct)
        if type(bases[0]) == type:
            return result
        if not hasattr(result, 'urls'):
            raise TypeError('Regex application without url definition.')
        compiled_urls = []
        for args in result.urls:
            args = list(args)
            args[0] = re.compile(args[0])
            compiled_urls.append(tuple(args))
        result.urls = compiled_urls
        return result


class RoutesMapperClass(type):
    """
    Metaclass that automatically creates a Routes mapper.
    """

    def __new__(cls, name, bases, dct):
        result = type.__new__(cls, name, bases, dct)
        if type(bases[0]) == type:
            return result
        if not hasattr(result, 'mapping'):
            raise TypeError('Route application without mapping.')
        from routes import Mapper
        mapper = Mapper()
        controllers = {}
        controller_map = {}
        for m in result.mapping:
            name = m[0].split('/', 1)[0]
            internal = str(id(m[1]))
            controllers[internal] = m[1]
            controller_map[m[1]] = internal
            kwargs = {}
            if len(m) >= 3 and not m[2] is None:
                kwargs['requirements'] = m[2]
            if len(m) == 4:
                kwargs.update(m[3])
            mapper.connect(name, m[0], controller=internal, **kwargs)
        mapper.create_regs(controllers.keys())
        result._routes_mapper = mapper
        result._routes_controllers = controllers
        result._controller_map = controller_map
        return result


class BaseApplication(object):
    """
    Base class for Colubrid applications.
    """

    def __init__(self, environ, start_response, request_class=Request):
        charset = 'utf-8'
        if hasattr(self, 'charset'):
            charset = self.charset
        self.request = request_class(environ, start_response, charset)
    
    def process_http_exception(self, exc):
        """Default routine to process a HttpException."""
        return HttpResponse(exc.get_error_page(), exc.get_headers(), exc.code)
    
    def process_request(self):
        """Process a request. Must be overridden."""
        raise NotImplementedError()
    
    def __iter__(self):
        try:
            response = self.process_request()
            if isinstance(self.request, ResponseRequest):
                response = self.request
            else:
                assert isinstance(response, HttpResponse), \
                       'process_request() must return a HttpResponse instance'
        except HttpException, exc:
            response = self.process_http_exception(exc)
        return response(self.request)


class RegexApplication(BaseApplication):
    """
    Application that maps URLs based on regular expressions.
    """
    __metaclass__ = RegexCompilerClass

    def process_request(self):
        """Process a single request."""
        path_info = self.request.environ.get('PATH_INFO', '/')[1:]
        if hasattr(self, 'slash_append') and self.slash_append:
            fix_slash(self.request.environ, True)
        for url, module in self.urls:
            matchobj = url.search(path_info)
            if not matchobj is None:
                args = matchobj.groups()
                if module in (True, False):
                    return fix_slash(self.request.environ, module)
                elif not '.' in module:
                    handler = getattr(self, module)
                else:
                    parts = module.split('.')
                    mname, fname = '.'.join(parts[:-1]), parts[-1]
                    package = __import__(mname, '', '', [''])
                    handler = getattr(package, fname)
                    args = list(args)
                    args.insert(0, self.request)
                    args = tuple(args)
                return handler(*args)
        raise PageNotFound()


class ResolveRegexApplication(BaseApplication):
    """
    Application that ...
    """
    __metaclass__ = RegexCompilerClass
    
    def process_request(self):
        """Process a single request."""
        path_info = self.request.environ.get('PATH_INFO', '/')[1:]
        if hasattr(self, 'slash_append') and self.slash_append:
            fix_slash(self.request.environ, True)
        for url, module in self.urls:
            matchobj = url.search(path_info)
            if not matchobj is None:
                args = matchobj.groups()
                new_args = []
                for pos, value in enumerate(args):
                    search = '$%d' % (pos + 1)
                    if search in module:
                        module = module.replace(search, value.replace('.', '_'))
                    else:
                        new_args.append(value)
                args = tuple(new_args)
                if not '.' in module:
                    if not hasattr(self, module):
                        raise PageNotFound
                    handler = getattr(self, module)
                else:
                    parts = module.split('.')
                    mname, fname = '.'.join(parts[:-1]), parts[-1]
                    try:
                        package = __import__(mname, '', '', [''])
                        handler = getattr(package, fname)
                    except (ImportError, AttributeError):
                        raise PageNotFound
                    args = list(args)
                    args.insert(0, self.request)
                    args = tuple(args)
                if handler in (True, False):
                    return fix_slash(self.request.environ, handler)
                return handler(*args)
        raise PageNotFound()


class WebpyApplication(BaseApplication):
    """
    Application compatible with web.py.
    """
    __metaclass__ = RegexCompilerClass
    
    def process_request(self):
        """Process a single request."""
        path_info = self.request.environ.get('PATH_INFO', '/')[1:]
        if hasattr(self, 'slash_append') and self.slash_append:
            fix_slash(self.request.environ, True)
        for url, cls in self.urls:
            matchobj = url.search(path_info)
            if not matchobj is None:
                cls = cls()
                cls.request = self.request
                handler = getattr(cls, self.request.environ['REQUEST_METHOD'])
                if handler in (True, False):
                    return fix_slash(self.request.environ, handler)
                return handler(*matchobj.groups())
        raise PageNotFound()


class PathApplication(BaseApplication):
    """
    Application that dispatches based on the first path element.
    """

    def process_request(self):
        """Process a single request."""
        path_info = self.request.environ.get('PATH_INFO', '/').strip('/')
        parts = path_info.strip('/').split('/')
        if not len(parts) or not parts[0]:
            handler = 'show_index'
            args = ()
        else:
            handler = 'show_%s' % parts[0]
            args = tuple(parts[1:])
        if hasattr(self, handler):
            return getattr(self, handler)(*args)
        fix_slash(self.request.environ, True)
        raise PageNotFound()


class ObjectApplication(BaseApplication):
    """
    A rather complex application type.
    It uses python class structures to handler the user requests.
    
    an ObjectApplication might look like this:
    
        class HelloWorld(object):
            def index(self):
                self.request.write('Hello World!')
            def name(self, name="Nobody"):
                self.request.write('Hello %s!' % name)
        
        class AdminPanel(object):
            def index(self):
                pass
            def login(self):
                pass
        
        class DispatcherApplication(ObjectApplication):
            root = HelloWorld
            root.admin = AdminPanel
            
        app = DispatcherApplication
    
    Let's say that the application listens on localhost:
    
        http://localhost/               --> HelloWorld.index()
        http://localhost/name/          --> HelloWorld.name('Nobody')
        http://localhost/name/Max       --> HelloWorld.name('Max')
        http://localhost/admin/         --> AdminPanel.index()
        http://localhost/admin/login    --> AdminPanel.login()
    """

    def process_request(self):
        """Process a single request."""
        if not hasattr(self, 'root'):
            raise AttributeError, 'ObjectApplication requires a root object.'
        
        path = self.request.environ.get('PATH_INFO', '').strip('/')
        parts = path.split('/')

        # Resolve the path
        handler = self.root
        args = []
        for part in parts:
            if part.startswith('_'):
                raise PageNotFound
            node = getattr(handler, part, None)
            if node is None:
                if part:
                    args.append(part)
            else:
                handler = node

        container = None

        # Find handler and make first container check
        import inspect
        if inspect.ismethod(handler):
            if handler.__name__ == 'index':
                # the handler is called index so it's the leaf of
                # itself. we don't want a slash, even if forced
                container = False
        else:
            index = getattr(handler, 'index', None)
            if not index is None:
                if not hasattr(index, 'container'):
                    container = True
                handler = index
            else:
                raise PageNotFound()

        # update with hardcoded container information
        if container is None and hasattr(handler, 'container'):
            container = handler.container
        
        # Check for handler arguments and update container
        handler_args, varargs, _, defaults = inspect.getargspec(handler)
        if defaults is None:
            defaults = 0
        else:
            defaults = len(defaults)

        max_len = len(handler_args) - 1
        min_len = max_len - defaults
        cur_len = len(args)
        if varargs:
            max_len = -1

        # check if the number of arguments fits our handler
        if max_len == -1:
            if cur_len < min_len:
                raise PageNotFound
        elif min_len <= cur_len <= max_len:
            if container is None:
                container = cur_len < max_len
        else:
            raise PageNotFound()

        if container is None:
            container = False
        fix_slash(self.request.environ, container)

        # call handler
        parent = handler.im_class()
        if hasattr(self, 'request'):
            parent.request = self.request
        return handler(parent, *args)


class RoutesApplication(BaseApplication):
    """
    Application that uses Routes (http://routes.groovie.org/) to
    dispatch URLs.
    """
    __metaclass__ = RoutesMapperClass

    def __init__(self, environ, start_response):
        def create_request(e, s, c):
            return RoutesRequest(self, e, s, c)
        super(RoutesApplication, self).__init__(environ, start_response,
                                                create_request)
        path = self.request.environ.get('PATH_INFO') or '/'
        match = self._routes_mapper.match(path)
        if match is None:
            raise PageNotFound()
        
        handler = self._routes_controllers[match['controller']]
        app = handler.im_class()
        app.request = self.request
        
        if match['action'] == 'index':
            del match['action']
        del match['controller']

        # XXX: can't return from __init__
        return handler(app, **match)
