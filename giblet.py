#!/usr/bin/python
# Summarizes large numbers of IP addresses and reports results in CIDR notation
# In the future I'll add a method that allows for adding subnets
#
# NOTE: This is very hackish at the time being due to deadlines. I hope to
# revisit this in the future to make it the giblet it always dreamt of
# becoming.
#
# <eric.gragsone@erisresearch.org>

import sys

def addr2ip(addr):
    q1=int(addr / 256**3) % 256
    q2=int(addr / 256**2) % 256
    q3=int(addr / 256) % 256
    q4=int(addr) % 256
    return str(q1)+'.'+str(q2)+'.'+str(q3)+'.'+str(q4)

def ip2addr(ip):
    x = map(int, ip.split('.'))
    return (256**3 * x[0]) + (256**2 * x[1]) + (256 * x[2]) + x[3]

class AddressBits:
    def __init__(self, cidr):
        self.value = 0
        self.I = None
        self.O = None
        self.addresses = []
        if cidr <= 32 and cidr > 0:
            self.cidr = cidr
            self.mask = 1 << (32 - cidr)
        else:
            print 'Error: Bad cidr = '+str(cidr)
    
    def store(self, addr):
        if addr not in self.addresses:
            self.addresses.append(addr)
            
            if len(self.addresses) * 2 > self.mask:
                if (self.I is not None) and (self.O is not None):
                    self.I = None
                    self.O = None
                    return
                elif (self.I is None) and (self.O is None):
                    return
            
            if self.cidr < 32:
                if addr & 1 << (32 - (self.cidr + 1)) > 0:
                    if self.I is None:
                        self.I = AddressBits(self.cidr+1)
                    
                    self.I.store(addr)
                else:
                    if self.O is None:
                        self.O = AddressBits(self.cidr+1)
                    
                    self.O.store(addr)

    def report(self, addr):
        if (self.I is None) and (self.O is None) and (self.addresses > 0):
            print addr2ip(addr)+'/'+str(self.cidr)+' '+str(len(self.addresses))
        elif len(self.addresses) > self.mask:
            print 'Error: Value > Mask'
        elif self.cidr == 32:
            print "At 32 value="+str(len(self.addresses))
        else:
            if self.O is not None:
                self.O.report(addr)
            
            if self.I is not None:
                addr = addr + (1 << (32 - (self.cidr + 1)))
                self.I.report(addr)

class Address:
    def __init__(self):
        self.I = AddressBits(1)
        self.O = AddressBits(1)
    
    def store(self, ip):
        addr=ip2addr(ip)
        
        if addr & (1 << 31) > 1:
            self.I.store(addr)
        else:
            self.O.store(addr)

    def report(self):
        self.O.report(0)
        self.I.report(1 << 31)

giblet = Address()

if len(sys.argv) > 1:
    filename=sys.argv[1]
    f=open(filename, 'r')
    
    for line in f:
        giblet.store(line.strip())

    giblet.report()
else:
    print 'Usage: '+sys.argv[0]+' <file>'