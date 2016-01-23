#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
  Split SEQATOMs files by SEQRES and SEQATOM
  File name: splitSEQATOMs.py
  Author: Nicolas Palopoli
  Date created: 2016/01/22
  Date last modified: 2016/01/22
  Python Version: 2.7
'''

import sys
from collections import OrderedDict
import csv
from Bio import SeqIO

# Read input files
try:
  infasta = open(sys.argv[1])
  pdb = sys.argv[2]
  chain = sys.argv[3]
except IndexError:
  print("Input file(s) not specified. Format: ./splitSEQATOMs.py <in.fasta> <pdb> <chain>")
  exit()
except IOError:
  print("Input file(s) not found. Format: ./splitSEQATOMs.py <in.fasta> <pdb> <chain>")
  exit()

def readFasta(infasta,pdb,chain):
  '''Store fasta sequences from file.'''
  seqs = OrderedDict()
  readFirstSeq = False
  for line in infasta:
    if line.strip() or line not in ['\n', '\r\n']:  # avoid empty or only whitespace lines
      line=line.rstrip()  # discard newline at the end (if any)
      if line[0]=='>':  # or line.startswith('>'); distinguish header
        if readFirstSeq:  # exit if more than 2 sequences
          break
        readFirstSeq = True
        words = line.split()
        name = pdb + ':' + chain
        seqs['res']=''
      else :  # sequence, not header, possibly multi-line
        seqs['res'] = seqs['res'] + line
  seqs['res'] = list(seqs['res'])
  return seqs

def splitSeq(seq):
  '''Split fasta sequence in SEQRES and SEQATOM'''
  seqlen = len(seq['res'])
# seq['SEQRES'] = seq['res'].upper()
  seq['SEQRES'] = map(lambda x:x.upper(),seq['res'])
# seq['SEQATOM'] = seq['res'].upper()
  seq['SEQATOM'] = map(lambda x:x.upper(),seq['res'])
  for pos in range(0,seqlen):
    if seq['res'][pos].islower():
      seq['SEQATOM'][pos] = '-'
  return seq

# Read input file
seq = readFasta(infasta,pdb,chain)
infasta.close()

seq = splitSeq(seq)

header = '|'.join([pdb,chain])
outname = 'SEQATOM_split_' + pdb + '_' + chain + '.fasta'
outfile=open(outname, 'w+')
print >>outfile, '{}{}|SEQRES'.format('>',''.join(header))
print >>outfile, ''.join(seq['SEQRES'])
print >>outfile, '{}{}|SEQATOM'.format('>',''.join(header))
print >>outfile, ''.join(seq['SEQATOM'])
outfile.close()
