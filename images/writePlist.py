#!/usr/bin/python

from plistlib import writePlist

d = dict()

for line in open ('icons.txt', 'rt'):
    li=line.strip()
    if not li.startswith('#'):
        a = [x for x in li.split('\t')]
        d[a[0]] = a[1:4]

writePlist(d, "icons.plist")
