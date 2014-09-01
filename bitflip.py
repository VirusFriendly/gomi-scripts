#!/usr/bin/python
# flips bits for subnet analysis for future topology project
# <eric.gragsone@erisresearch.org>
import sys

if len(sys.argv) > 1:
  x=int(sys.argv[1])
  y=0;
  mask=0;
else :
  print 'Usage: '+sys.argv[0]+' <number less than 256>'

if x > 255:
  x=x%255

for i in range(0, 8):
  y=1<<i
  mask=mask|y
  print ''+str(y^x)+"\t"+'/'+str(y)+' '+str(x^mask)
