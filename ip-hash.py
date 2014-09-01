#!/usr/bin/python
# finds and obfuscates ip addresses to protect sensitive data
# <eric.gragsone@erisresearch.org>

import re, sys, zlib

ip = re.compile('[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

if len(sys.argv) > 2:
    key=sys.argv[1]
    filename=sys.argv[2]
    f=open(filename, 'r')
    
    for line in f:
        for host in ip.findall(line):
            scrubhash=format(abs(zlib.crc32(key+host)), 'x')
            '''print 'host: '+host+' and key:'+key+' creates hash:'+scrubhash'''
            line=line.replace(host, scrubhash)
        
        print(line),
else:
    print 'Usage: '+sys.argv[0]+' <hash key> <file>'
