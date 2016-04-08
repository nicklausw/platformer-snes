#!/usr/bin/env python3
# basic rle compression program
# by nicklausw
# public domain.

import sys
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("in_file", help="the chr data to be rle'd")
parser.add_argument("out_file", help="the rle'd output")
args = parser.parse_args()

f_in = open(args.in_file, 'rb')
f_out = open(args.out_file, 'wb')

# python doesn't need variable initialization i think,
# but for clarity's sake.
byte_n = 0 # byte
byte_c = 1 # byte count 

for c in f_in.read():
  if c != byte_n or byte_c == 0xFE:
    f_out.write(bytes([byte_c]))
    f_out.write(bytes([byte_n]))
    byte_c = 1
    byte_n = c
  else:
    byte_c += 1

# now catch the last time around
f_out.write(bytes([byte_c]))
f_out.write(bytes([byte_n]))

# the end mark
f_out.write(bytes([0xFF]))

f_in.close()
f_out.close()
