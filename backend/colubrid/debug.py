# -*- coding: utf-8 -*-
"""
    Colubrid Debugging Module
    =========================

    Adds debug support to colubrid applications.
"""
from __future__ import generators
import os
import sys
import re
import traceback
import keyword
import token
import tokenize
import string
import pprint
import inspect
import threading
import cgi
from random import random
from cStringIO import StringIO
from xml.sax.saxutils import escape

JAVASCRIPT = r'''
function toggleBlock(handler) {
    if (handler.nodeName == 'H3') {
        var table = handler;
        do {
            table = table.nextSibling;
            if (typeof table == 'undefined') {
                return;
            }
        }
        while (table.nodeName != 'TABLE');
    }
    
    else if (handler.nodeName == 'DT') {
        var parent = handler.parentNode;
        var table = parent.getElementsByTagName('TABLE')[0];
    }
    
    var lines = table.getElementsByTagName("TR");
    for (var i = 0; i < lines.length; i++) {
        var line = lines[i];
        if (line.className == 'pre' || line.className == 'post') {
            line.style.display = (line.style.display == 'none') ? '' : 'none';
        }
        else if (line.parentNode.parentNode.className == 'vars' ||
                 line.parentNode.parentNode.className == 'exec_code') {
            line.style.display = (line.style.display == 'none') ? '' : 'none';
            var input = line.getElementsByTagName('TEXTAREA');
            if (input.length) {
                input[0].focus();
            }
        }
    }
}

function initTB() {
    var tb = document.getElementById('wsgi-traceback');
    var handlers = tb.getElementsByTagName('H3');
    for (var i = 0; i < handlers.length; i++) {
        toggleBlock(handlers[i]);
        handlers[i].setAttribute('onclick', 'toggleBlock(this)');
    }
    handlers = tb.getElementsByTagName('DT');
    for (var i = 0; i < handlers.length; i++) {
        toggleBlock(handlers[i]);
        handlers[i].setAttribute('onclick', 'toggleBlock(this)');
    }
    var handlers = tb.getElementsByTagName('TEXTAREA');
    for (var i = 0; i < handlers.length; i++) {
        var hid = handlers[i].getAttribute('id');
        if (hid && hid.substr(0, 6) == 'input-') {
            var p = handlers[i].getAttribute('id').split('-');
            handlers[i].onkeyup = makeEnter(p[1], p[2]);
        }
    }
}

AJAX_ACTIVEX = ['Msxml2.XMLHTTP', 'Microsoft.XMLHTTP', 'Msxml2.XMLHTTP.4.0'];

function ajaxConnect() {
    var con = null;
    try {
        con = new XMLHttpRequest();
    }
    catch (e) {
        if (typeof AJAX_ACTIVEX == 'string') {
            con = new ActiveXObject(AJAX_ACTIVEX);
        }
        else {
            for (var i=0; i < AJAX_ACTIVEX.length; i++) {
                var axid = AJAX_ACTIVEX[i];
                try {
                    con = new ActiveXObject(axid);
                }
                catch (e) {}
                if (con) {
                    AJAX_ACTIVEX = axid;
                    break;
                }
            }
        }
    }
    return con;
}

function execCode(traceback, frame) {
    var input = document.getElementById('input-' + traceback + '-' +
                                        frame);
    var e = encodeURIComponent;
    var data = 'tb=' + e(traceback) + '&' +
               'frame=' + e(frame) + '&' +
               'code=' + e(input.value);
    writeToOutput(traceback, frame, '>>> ' + input.value);
    var con = ajaxConnect();
    con.onreadystatechange = function() {
        if (con.readyState == 4 && con.status == 200) {
            writeToOutput(traceback, frame, con.responseText);
            input.focus();
            input.value = '';
        }
    };
    con.open('GET', '__traceback__?' + data);
    con.send(data);
}

function makeEnter(traceback, frame) {
    return function(e) {
        var e = (e) ? e : window.event;
        var code = (e.keyCode) ? e.keyCode : e.which;
        if (code == 13) {
            var input = document.getElementById('input-' + traceback +
                                                '-' + frame);
            if (input.className == 'big') {
                if (input.value.substr(input.value.length - 2) != '\n\n') {
                    return;
                }
                input.value = input.value.substr(0, input.value.length - 1);
                input.className = 'small';
            }
            if (input.value == 'clear\n') {
                clearOutput(traceback, frame);
                input.value = '';
            }
            else {
                execCode(traceback, frame);
            }
        }
    }
}

function writeToOutput(traceback, frame, text) {
    var output = document.getElementById('output-' + traceback + '-' +
                                         frame);
    if (text && text != '\n') {
        var node = document.createTextNode(text);
        output.appendChild(node);
    }
}

function clearOutput(traceback, frame) {
    var output = document.getElementById('output-' + traceback + '-' +
                                         frame);
    output.innerHTML = '';
}

function toggleExtend(traceback, frame) {
    var input = document.getElementById('input-' + traceback + '-' +
                                        frame);
    input.className = (input.className == 'small') ? 'big' : 'small';
    input.focus();
}

function change_tb() {
    interactive = document.getElementById('interactive');
    plain = document.getElementById('plain');
    interactive.style.display = ((interactive.style.display == 'block') | (interactive.style.display == '')) ? 'none' : 'block';
    plain.style.display = (plain.style.display == 'block') ? 'none' : 'block';
}
'''

STYLESHEET = '''
body {
  font-size:0.9em;
}

* {
  margin:0;
  padding:0;
}

#wsgi-traceback {
  margin: 1em;
  border: 1px solid #5F9CC4;
  background-color: #F6F6F6;
}

.footer {
  margin: 1em;
  text-align: right;
  font-style: italic;
}

h1 {
  background-color: #3F7CA4;
  font-size:1.2em;
  color:#FFFFFF;
  padding:0.3em;
  margin:0 0 0.2em 0;
}

h2 {
  background-color:#5F9CC4;
  font-size:1em;
  color:#FFFFFF;
  padding:0.3em;
  margin:0.4em 0 0.2em 0;
}

h2.tb {
  cursor:pointer;
}

h3 {
  font-size:1em;
  cursor:pointer;
}

h3.fn {
  margin-top: 0.5em;
}

h3.fn:hover:before {
  content: "\\21D2   ";
}

h3.indent {
  margin:0 0.7em 0 0.7em;
  font-weight:normal;
}

p.text {
  padding:0.1em 0.5em 0.1em 0.5em;
}

p.important {
  font-weight: bold;
}

div.frame {
  margin:0 1em 0 1em;
}

table.code {
  margin:0.5em 0.7em 0.3em 0.7em;
  background-color:#E0E0E0;
  width:100%;
  font-size:0.9em;
  border:1px solid #C9C9C9;
  border-collapse:collapse;
}

table.code td.lineno {
  width:42px;
  text-align:right;
  padding:0 5px 0 0;
  color:#444444;
  border-right:1px solid #888888;
}

table.code td.code {
  background-color:#EFEFEF;
  padding:0 0 0 5px;
  white-space:pre;
}

table.code tr.cur td.code {
  background-color: #FAFAFA;
  padding: 1px 0 1px 5px;
  white-space: pre;
}

pre.plain {
  margin:0.5em 1em 1em 1em;
  padding:0.5em;
  border:1px solid #999999;
  background-color: #FFFFFF;
  line-height: 120%;
  font-family: monospace;
}

table.exec_code {
  width:100%;
  margin:0 1em 0 1em;
}

table.exec_code td.input {
  width:100%;
}

table.exec_code textarea.small {
  width:100%;
  height:1.5em;
  border:1px solid #999999;
}

table.exec_code textarea.big {
  width:100%;
  height:5em;
  border:1px solid #999999;
}

table.exec_code input {
  height:1.5em;
  border:1px solid #999999;
  background-color:#FFFFFF;
}

table.exec_code td.extend {
  width:70px;
  padding:0 5px 0 5px;
}

table.exec_code td.output pre {
  font-family: monospace;
  white-space: pre-wrap;       /* css-3 should we be so lucky... */
  white-space: -moz-pre-wrap;  /* Mozilla, since 1999 */
  white-space: -pre-wrap;      /* Opera 4-6 ?? */
  white-space: -o-pre-wrap;    /* Opera 7 ?? */
  word-wrap: break-word;       /* Internet Explorer 5.5+ */
  _white-space: pre;   /* IE only hack to re-specify in addition to word-wrap  */
}

table.vars {
  margin:0 1.5em 0 1.5em;
  border-collapse:collapse;
  font-size: 0.9em;
}

table.vars td {
  font-family: 'Bitstream Vera Sans Mono', 'Courier New', monospace;
  padding: 0.3em;
  border: 1px solid #ddd;
  vertical-align: top;
  background-color: white;
}

table.vars .name {
  font-style: italic;
}

table.vars .value {
  color: #555;
}

table.vars th {
  padding: 0.2em;
  border: 1px solid #ddd;
  background-color: #f2f2f2;
  text-align: left;
}

#plain {
  display: none;
}

dl dt {
    padding: 0.2em 0 0.2em 1em;
    font-weight: bold;
    cursor: pointer;
    background-color: #ddd;
}

dl dt:hover {
    background-color: #bbb; color: white;
}

dl dd {
    padding: 0 0 0 2em;
    background-color: #eee;
}

span.p-kw {
  font-weight:bold;
}

span.p-cmt {
  color:#8CBF83;
}

span.p-str {
  color:#DEA39B;
}

span.p-num {
  color:#D2A2D6;
}

span.p-op {
    color:#0000AA;
}
'''


def get_uid():
    return str(random()).encode('base64')[3:11]


def get_frame_info(tb, context_lines=7):
    """
    Return a dict of informations about a given traceback.
    """
    # line numbers / function / variables
    lineno = tb.tb_lineno
    function = tb.tb_frame.f_code.co_name
    variables = tb.tb_frame.f_locals

    # get filename
    fn = tb.tb_frame.f_globals.get('__file__')
    if not fn:
        fn = os.path.realpath(inspect.getsourcefile(tb) or
                              inspect.getfile(tb))
    if fn[-4:] in ('.pyc', '.pyo'):
        fn = fn[:-1]

    # module name
    modname = tb.tb_frame.f_globals.get('__name__')

    # get loader
    loader = tb.tb_frame.f_globals.get('__loader__')

    # sourcecode
    try:
        if not loader is None:
            source = loader.get_source(modname)
        else:
            source = file(fn).read()
    except:
        source = ''
        pre_context, post_context = [], []
        context_line, context_lineno = None, None
    else:
        parser = PythonParser(source)
        parser.parse()
        parsed_source = parser.get_html_output()
        lbound = max(0, lineno - context_lines - 1)
        ubound = lineno + context_lines
        try:
            context_line = parsed_source[lineno - 1]
            pre_context = parsed_source[lbound:lineno - 1]
            post_context = parsed_source[lineno:ubound]
        except IndexError:
            context_line = None
            pre_context = post_context = [], []
        context_lineno = lbound

    return {
        'tb':               tb,
        'filename':         fn,
        'loader':           loader,
        'function':         function,
        'lineno':           lineno,
        'vars':             variables,
        'pre_context':      pre_context,
        'context_line':     context_line,
        'post_context':     post_context,
        'context_lineno':   context_lineno,
        'source':           source
    }


def debug_info(request, context=None, evalex=True):
    """
    Return debug info for the request
    """
    if context is None:
        context = Namespace()

    req_vars = []
    for item in dir(request):
        attr = getattr(request, item)
        if not (item.startswith("_") or inspect.isroutine(attr)):
            req_vars.append((item, attr))
    req_vars.sort()

    context.req_vars = req_vars
    return DebugRender(context, evalex).render()


def get_current_thread():
    return threading.currentThread()


class Namespace(object):
    def __init__(self, **kwds):
        self.__dict__.update(kwds)


class ThreadedStream(object):
    _orig = None

    def __init__(self):
        self._buffer = {}

    def install(cls, environ):
        if cls._orig or not environ['wsgi.multithread']:
            return
        cls._orig = sys.stdout
        sys.stdout = cls()
    install = classmethod(install)

    def can_interact(cls):
        return not cls._orig is None
    can_interact = classmethod(can_interact)

    def push(self):
        tid = get_current_thread()
        self._buffer[tid] = StringIO()

    def release(self):
        tid = get_current_thread()
        if tid in self._buffer:
            result = self._buffer[tid].getvalue()
            del self._buffer[tid]
        else:
            result = ''
        return result

    def write(self, d):
        tid = get_current_thread()
        if tid in self._buffer:
            self._buffer[tid].write(d)
        else:
            self._orig.write(d)


class EvalContext(object):

    def __init__(self, frm):
        self.locals = frm.f_locals
        self.globals = frm.f_globals

    def exec_expr(self, s):
        sys.stdout.push()
        try:
            try:
                code = compile(s, '<stdin>', 'single', 0, 1)
                exec code in self.globals, self.locals
            except:
                etype, value, tb = sys.exc_info()
                tb = tb.tb_next
                msg = ''.join(traceback.format_exception(etype, value, tb))
                sys.stdout.write(msg)
        finally:
            output = sys.stdout.release()
        return output


class PythonParser(object):
    """
    Simple python sourcecode highlighter.
    Usage::

        p = PythonParser(source)
        p.parse()
        for line in p.get_html_output():
            print line
    """

    _KEYWORD = token.NT_OFFSET + 1
    _TEXT    = token.NT_OFFSET + 2
    _classes = {
        token.NUMBER:       'num',
        token.OP:           'op',
        token.STRING:       'str',
        tokenize.COMMENT:   'cmt',
        token.NAME:         'id',
        token.ERRORTOKEN:   'error',
        _KEYWORD:           'kw',
        _TEXT:              'txt',
    }

    def __init__(self, raw):
        self.raw = raw.expandtabs(8).strip()
        self.out = StringIO()

    def parse(self):
        self.lines = [0, 0]
        pos = 0
        while 1:
            pos = string.find(self.raw, '\n', pos) + 1
            if not pos: break
            self.lines.append(pos)
        self.lines.append(len(self.raw))

        self.pos = 0
        text = StringIO(self.raw)
        try:
            tokenize.tokenize(text.readline, self)
        except tokenize.TokenError:
            pass

    def get_html_output(self):
        """ Return line generator. """
        def html_splitlines(lines):
            # this cool function was taken from trac.
            # http://projects.edgewall.com/trac/
            open_tag_re = re.compile(r'<(\w+)(\s.*)?[^/]?>')
            close_tag_re = re.compile(r'</(\w+)>')
            open_tags = []
            for line in lines:
                for tag in open_tags:
                    line = tag.group(0) + line
                open_tags = []
                for tag in open_tag_re.finditer(line):
                    open_tags.append(tag)
                open_tags.reverse()
                for ctag in close_tag_re.finditer(line):
                    for otag in open_tags:
                        if otag.group(1) == ctag.group(1):
                            open_tags.remove(otag)
                            break
                for tag in open_tags:
                    line += '</%s>' % tag.group(1)
                yield line
                
        return list(html_splitlines(self.out.getvalue().splitlines()))
            

    def __call__(self, toktype, toktext, (srow,scol), (erow,ecol), line):
        oldpos = self.pos
        newpos = self.lines[srow] + scol
        self.pos = newpos + len(toktext)

        if toktype in [token.NEWLINE, tokenize.NL]:
            self.out.write('\n')
            return

        if newpos > oldpos:
            self.out.write(self.raw[oldpos:newpos])

        if toktype in [token.INDENT, token.DEDENT]:
            self.pos = newpos
            return

        if token.LPAR <= toktype and toktype <= token.OP:
            toktype = token.OP
        elif toktype == token.NAME and keyword.iskeyword(toktext):
            toktype = self._KEYWORD
        clsname = self._classes.get(toktype, 'txt')

        self.out.write('<span class="code-item p-%s">' % clsname)
        self.out.write(escape(toktext))
        self.out.write('</span>')


class DebugRender(object):

    def __init__(self, context, evalex):
        self.c = context
        self.evalex = evalex
        
    def render(self):
        return '\n'.join([
            self.header(),
            self.traceback(),
            self.request_information(),
            self.footer()
        ])
        
    def header(self):
        data = [
            '<script type="text/javascript">%s</script>' % JAVASCRIPT,
            '<style type="text/css">%s</style>' % STYLESHEET,
            '<div id="wsgi-traceback">'
        ]
        
        if hasattr(self.c, 'exception_type'):
            title = escape(self.c.exception_type)
            exc = escape(self.c.exception_value)
            data += [
                '<h1>%s</h1>' % title,
                '<p class="text important">%s</p>' % exc
            ]

        if hasattr(self.c, 'last_frame'):
            data += [
                '<p class="text important">%s in %s, line %s</p>' % (
                self.c.last_frame['filename'], self.c.last_frame['function'],
                self.c.last_frame['lineno'])
            ]

        return '\n'.join(data)

    def render_code(self, frame):
        def render_line(mode, lineno, code):
            return ''.join([
                '<tr class="%s">' % mode,
                '<td class="lineno">%i</td>' % lineno,
                '<td class="code">%s</td></tr>' % code
            ])

        tmp = ['<table class="code">']
        lineno = frame['context_lineno']
        if not lineno is None:
            lineno += 1
            for l in frame['pre_context']:
                tmp.append(render_line('pre', lineno, l))
                lineno += 1
            tmp.append(render_line('cur', lineno, frame['context_line']))
            lineno += 1
            for l in frame['post_context']:
                tmp.append(render_line('post', lineno, l))
                lineno += 1
        else:
            tmp.append(render_line('cur', 1, 'Sourcecode not available'))
        tmp.append('</table>')
        
        return '\n'.join(tmp)
        
    def var_table(self, var):
        # simple data types
        if isinstance(var, basestring) or isinstance(var, float)\
           or isinstance(var, int) or isinstance(var, long):
            return ('<table class="vars"><tr><td class="value">%r'
                    '</td></tr></table>' % var)
        
        # dicts
        if isinstance(var, dict) or hasattr(var, 'items'):
            items = var.items()
            items.sort()

            # empty dict
            if not items:
                return ('<table class="vars"><tr><th>no data given'
                        '</th></tr></table>')
        
            result = ['<table class="vars"><tr><th>Name'
                      '</th><th>Value</th></tr>']
            for key, value in items:
                try:
                    val = escape(pprint.pformat(value))
                except:
                    val = '?'
                result.append('<tr><td class="name">%s</td><td class="value">%s'
                              '</td></tr>' % (escape(repr(key)), val))
            result.append('</table>')
            return '\n'.join(result)

        # lists
        if isinstance(var, list):
            # empty list
            if not var:
                return ('<table class="vars"><tr><th>no data given'
                        '</th></tr></table>')

            result = ['<table class="vars">']
            for line in var:
                try:
                    val = escape(pprint.pformat(line))
                except:
                    val = '?'
                result.append('<tr><td class="value">%s</td></tr>' % (val))
            result.append('</table>')
            return '\n'.join(result)
        
        # unknown things
        try:
            value = escape(repr(var))
        except:
            value = '?'
        return '<table class="vars"><tr><th>%s</th></tr></table>' % value

    def exec_code_table(self, uid):
        return '''
        <table class="exec_code">
          <tr>
            <td class="output" colspan="2"><pre id="output-%(tb_uid)s-%(frame_uid)s"></pre></td>
           </tr>
          <tr>
            <td class="input">
              <textarea class="small" id="input-%(tb_uid)s-%(frame_uid)s" value=""></textarea>
            </td>
            <td class="extend">
              <input type="button" onclick="toggleExtend('%(tb_uid)s', '%(frame_uid)s')" value="extend">
            </td>
          </tr>
        </table>
        ''' % {
            'target': '#',
            'tb_uid': self.c.tb_uid,
            'frame_uid': uid
        }

    def traceback(self):
        if not hasattr(self.c, 'frames'):
            return ''

        result = ['<h2 onclick="change_tb()" class="tb">Traceback (click to switch to raw view)</h2>']
        result.append('<div id="interactive"><p class="text">A problem occurred in your Python WSGI'
        ' application. Here is the sequence of function calls leading up to'
        ' the error, in the order they occurred. Click on a header to show'
        ' context lines.</p>')
        
        for num, frame in enumerate(self.c.frames):
            line = [
                '<div class="frame" id="frame-%i">' % num,
                '<h3 class="fn">%s in %s</h3>' % (frame['function'],
                                                  frame['filename']),
                self.render_code(frame),
            ]
                
            if frame['vars']:
                line.append('\n'.join([
                    '<h3 class="indent">&rArr; local variables</h3>',
                    self.var_table(frame['vars'])
                ]))

            if self.evalex and self.c.tb_uid:
                line.append('\n'.join([
                    '<h3 class="indent">&rArr; execute code</h3>',
                    self.exec_code_table(frame['frame_uid'])
                ]))
            
            line.append('</div>')
            result.append(''.join(line))
        result.append('\n'.join([
            '</div>',
            self.plain()
        ]))
        return '\n'.join(result)

    def plain(self):
        if not hasattr(self.c, 'plaintb'):
            return ''
        return '''
        <div id="plain">
        <p class="text">Here is the plain Python traceback for copy and paste:</p>
        <pre class="plain">\n%s</pre>
        </div>
        ''' % self.c.plaintb
        
    def request_information(self):
        result = [
            '<h2>Request Data</h2>',
            '<p class="text">The following list contains all important',
            'request variables. Click on a header to expand the list.</p>'
        ]

        if not hasattr(self.c, 'frames'):
            del result[0]
        
        for key, info in self.c.req_vars:
            result.append('<dl><dt>%s</dt><dd>%s</dd></dl>' % (
                escape(key), self.var_table(info)
            ))
        
        return '\n'.join(result)
        
    def footer(self):
        return '\n'.join([
            '<script type="text/javascript">initTB();</script>',
            '</div>',
            '<div class="footer">Brought to you by '
                '<span style="font-style: normal">DON\'T PANIC</span>, your friendly '
                'Colubrid traceback interpreter system.</div>',
            hasattr(self.c, 'plaintb')
                and ('<!-- Plain traceback:\n\n%s-->' % self.c.plaintb)
                or '',
        ])
        


class DebuggedApplication(object):
    """
    Enables debugging support for a given application::

        from colubrid.debug import DebuggedApplication
        from myapp import app
        app = DebuggedApplication(app)

    Or for a whole package::
        
        app = DebuggedApplication("myapp:app")
    """

    def __init__(self, application, evalex=True):
        self.evalex = bool(evalex)
        if not isinstance(application, basestring):
            self.application = application
        else:
            try:
                self.module, self.handler = application.split(':', 1)
            except ValueError:
                self.module = application
                self.handler = 'app'
        self.tracebacks = {}
    
    def __call__(self, environ, start_response):
        # exec code in open tracebacks
        if self.evalex and environ.get('PATH_INFO', '').strip('/').endswith('__traceback__'):
            parameters = cgi.parse_qs(environ['QUERY_STRING'])
            try:
                tb = self.tracebacks[parameters['tb'][0]]
                frame = parameters['frame'][0]
                context = tb[frame]
                code = parameters['code'][0].replace('\r','')
            except (IndexError, KeyError):
                pass
            else:
                result = context.exec_expr(code)
                start_response('200 OK', [('Content-Type', 'text/plain')])
                yield result
                return
        appiter = None
        try:
            if hasattr(self, 'application'):
                result = self.application(environ, start_response)
            else:
                module = __import__(self.module, '', '', [''])
                app = getattr(module, self.handler)
                result = app(environ, start_response)
            appiter = iter(result)
            for line in appiter:
                yield line
        except:
            ThreadedStream.install(environ)
            exc_info = sys.exc_info()
            try:
                headers = [('Content-Type', 'text/html')]
                start_response('500 INTERNAL SERVER ERROR', headers)
            except:
                pass
            debug_context = self.get_debug_context(exc_info)
            yield debug_info(environ.get('colubrid.request'), debug_context, self.evalex)
        
        if hasattr(appiter, 'close'):
            appiter.close()

    def get_debug_context(self, exc_info):
        exception_type, exception_value, tb = exc_info
        # skip first internal frame
        if not tb.tb_next is None:
            tb = tb.tb_next
        plaintb = ''.join(traceback.format_exception(*exc_info))

        # load frames
        frames = []
        frame_map = {}
        tb_uid = None
        if ThreadedStream.can_interact():
            tb_uid = get_uid()
            frame_map = self.tracebacks[tb_uid] = {}

        # walk through frames and collect informations
        while tb is not None:
            if tb_uid:
                frame_uid = get_uid()
                frame_map[frame_uid] = EvalContext(tb.tb_frame)
            else:
                frame_uid = None
            frame = get_frame_info(tb)
            frame['frame_uid'] = frame_uid
            frames.append(frame)
            tb = tb.tb_next

        if exception_type.__module__ == "exceptions":
            extypestr = exception_type.__name__
        else:
            extypestr = str(exception_type)

        return Namespace(
            exception_type =  extypestr,
            exception_value = str(exception_value),
            frames =          frames,
            last_frame =      frames[-1],
            plaintb =         plaintb,
            tb_uid =          tb_uid,
            frame_map =       frame_map
        )

