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

def toseed(seq, n):
    return [seq[x::n] for x in range(n)]

if len(sys.argv) != 3:
    print("\033[95m♡ pls use : python superseed.py <fasta_path> <n>\033[0m")
    sys.exit(1)

fastapath, n = sys.argv[1], int(sys.argv[2])

input_name = os.path.splitext(os.path.basename(fastapath))[0]
output_path = f'{input_name}_N{n}.fasta'

with open(output_path, 'w') as output_file:
    for seqid, seqfr in parsefasta(fastapath):
        seeds = toseed(seqfr, n)
        for x, myseeds in enumerate(seeds):
            output_file.write(f'>{seqid}_part{x+1}\n{myseeds}\n')

