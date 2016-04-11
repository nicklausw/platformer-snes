#!/usr/bin/env python3
# basic rle compression program
# by nicklausw
# public domain.

# this format works as follows.
# one byte is read, and that is
# how many of the next byte to copy over. repeat.
# when the first byte is $ff, the copy is done.

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
byte_n = int.from_bytes(f_in.read(1), byteorder='little') # byte
byte_c = 0 # byte count

f_in.seek(0) 

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
