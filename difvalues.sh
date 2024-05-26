#!/bin/bash

SEED_SCRIPT="./superseed.py"

if [ "$#" -ne 1 ]; then
    echo -e "\033[95m♡Pls use: $0 <original.fasta>\033[0m"
    exit 1
fi

FASTA_FILE="$1"

# Generate FASTA files with seeds using Python script
for N_VALUE in {2..10}; do
    python3 "$SEED_SCRIPT" "$FASTA_FILE" "$N_VALUE"
done

