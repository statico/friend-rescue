# -*- coding: utf-8 -*-
"""
    Reloader Module
    ===============

    Taken from django, which took it from cherrypy / paste
"""
# Portions copyright (c) 2004, CherryPy Team (team@cherrypy.org)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice,
#       this list of conditions and the following disclaimer in the documentation
#       and/or other materials provided with the distribution.
#     * Neither the name of the CherryPy Team nor the names of its contributors
#       may be used to endorse or promote products derived from this software
#       without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import os
import sys
import thread
import time

RUN_RELOADER = True

def reloader_thread(watch):
    """This thread watches Python and "watch" files and reloads the
    application if something changes."""
    mtimes = {}
    win = sys.platform == 'win32'
    
    while RUN_RELOADER:
        for filename in [getattr(m, '__file__', '') for m
                         in sys.modules.values()] + watch:
            if filename[-4:] in ('.pyo', '.pyc'):
                filename = filename[:-1]
            if not os.path.exists(filename):
                continue
            stat = os.stat(filename)
            mtime = stat.st_mtime
            if win:
                mtime -= stat.st_ctime
            if filename not in mtimes:
                mtimes[filename] = mtime
                continue
            if mtime != mtimes[filename]:
                sys.exit(3) # force reload
        time.sleep(1)


def restart_with_reloader():
    """Spawn a new Python interpreter with the same arguments as this one,
    but running the reloader thread."""
    while True:
        args = [sys.executable] + sys.argv
        if sys.platform == 'win32':
            args = ['"%s"' % arg for arg in args]
        new_environ = os.environ.copy()
        new_environ['RUN_MAIN'] = 'true'
        exit_code = os.spawnve(os.P_WAIT, sys.executable, args, new_environ)
        if exit_code != 3:
            return exit_code


def main(main_func, watch=[]):
    """Call this to initialize the reloader."""
    if os.environ.get('RUN_MAIN') == 'true':
        thread.start_new_thread(main_func, ())
        try:
            reloader_thread(watch)
        except KeyboardInterrupt:
            pass
    else:
        try:
            sys.exit(restart_with_reloader())
        except KeyboardInterrupt:
            pass
