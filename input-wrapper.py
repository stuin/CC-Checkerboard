#!/usr/bin/python

class _Getch:
    """Gets a single character from standard input.  Does not echo to the
screen."""
    def __init__(self):
        try:
            self.impl = _GetchWindows()
        except ImportError:
            self.impl = _GetchUnix()

    def __call__(self):
        try:
            return self.impl()
        except:
            pass
        return ''


class _GetchUnix:
    def __init__(self):
        import tty, sys

    def __call__(self):
        import sys, tty, termios
        fd = sys.stdin.fileno()
        old_settings = termios.tcgetattr(fd)
        try:
            tty.setraw(sys.stdin.fileno())
            ch = sys.stdin.read(1)
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        return ch


class _GetchWindows:
    def __init__(self):
        import msvcrt

    def __call__(self):
        import msvcrt
        return msvcrt.getch()

getch = _Getch()

import sys
import subprocess
import time

#Enable mouse
subprocess.run(['stty', '-echo'])
print("\x1B[?1003h")

#Run provided file in lua
command = ['lua', sys.argv[1]]
p = subprocess.Popen(command, stdin=subprocess.PIPE)

#Take input one character at a time
c = '0'
while p.poll() is None and c[0] != 'Q':
    c = getch()

    #Collect escaped mouse input as one string
    if c == "\x1B":
        for i in range(0,5):
            c += getch()
    c+="\n"

    #Pass input to lua program stdin
    if len(c)<3 or c[3] == '#':
        #print(c)
        p.stdin.write(c.encode())
        p.stdin.flush()

p.communicate()
print("\x1B[?1000l")