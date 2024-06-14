#!/usr/bin/env python3
from Bio import SeqIO
import sys
import os

def parsefasta(fastapath):
    seq = []
    for x in SeqIO.parse(fastapath, 'fasta'):
        nuc = ''.join([base for base in x.seq if base in 'ACGTacgt'])
        seq.append((x.id, nuc))
    return seq

def toseed(seq, x, y):
    seq1 = ''.join([seq[i] for i in range(len(seq)) if (i % (x + y)) < x])
    seq2 = ''.join([seq[i] for i in range(len(seq)) if (i % (x + y)) >= x])
    return seq1, seq2

if len(sys.argv) != 4:
    print("\033[95m♡ pls use : python superseed.py <fasta_path> <x> <y>\033[0m")
    sys.exit(1)

fastapath, x, y = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])

input_name = os.path.splitext(os.path.basename(fastapath))[0]
output_path = f'data/{input_name}_X{x}_Y{y}.fa'

with open(output_path, 'w') as output_file:
    for seqid, seqfr in parsefasta(fastapath):
        seq1, seq2 = toseed(seqfr, x, y)
        output_file.write(f'>{seqid}_part1\n{seq1}\n')
        output_file.write(f'>{seqid}_part2\n{seq2}\n')
