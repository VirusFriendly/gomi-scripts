#! /usr/bin/python
# Script to parse a PCAP and XOR data based on a byte offset
#
# http://www.rsreese.com/decoding-xor-payload-using-first-few-bytes-as-key/
#
# Requires Scapy
# 0.1 - 07172012
# Default is two bytes, change at line 35
# Stephen Reese and Eric Gragsone
#
# todo: add two more args, offset length and static offset option

from scapy.all import *
import sys

# Get input and output files from command line
if len(sys.argv) < 2:
    print "Usage: decodexorpayload.py [input pcap file]"
    sys.exit(1)

# Assign variable names for input and output files
infile = sys.argv[1]

def many_byte_xor(buf, key):
    buf = bytearray(buf)
    key = bytearray(key)
    key_len = len(key)
    for i, bufbyte in enumerate(buf):
        buf[i] = bufbyte ^ key[i % key_len]
    return str(buf)

def process_packets():
    pkts = rdpcap(infile)
    cooked=[]
    for p in pkts:
        # You may have to adjust the payload depth here:
        # i.e. p.payload.payload.payload
        pkt_payload = str(p.payload.payload)
        pkt_offset = str(p.payload.payload)[:3]
        if pkt_payload and pkt_offset:
              pmod=p
              # You may have to adjust the payload depth here:
              p.payload.payload=many_byte_xor(pkt_payload, pkt_offset)
              cooked.append(pmod)

    wrpcap("dump.pcap", cooked)

process_packets()
