#!/bin/bash

SCRIPT="./seedtostats.sh"

if [ "$#" -ne 1 ]; then
    echo -e "\033[95m♡Pls use: $0 -k <valeur_k> -n <valeur_n> <original.fasta>\033[0m"
    exit 1
fi

FASTA_FILE="$1"
ORIGINAL_FASTA="$FASTA_FILE"

for K_VALUE in 21 31 41 51 61; do
    for N_VALUE in {2..10}; do
        $SCRIPT -k "$K_VALUE" -n "$N_VALUE" "$ORIGINAL_FASTA"
    done
done

