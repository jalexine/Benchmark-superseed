#!/bin/bash

export PATH="$(pwd):$PATH"

while getopts ":k:n:" opt; do
  case $opt in
    k) K_VALUE=$OPTARG ;;
    n) N_VALUE=$OPTARG ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
  esac
done

shift $((OPTIND-1))

if [ "$#" -ne 1 ]; then
    echo -e "\033[95m♡Pls usesage: $0 -k <value_k> -n <value_n> <original.fasta>\033[0m"
    exit 1
fi

ORIGINAL_FASTA=$1
SD_FASTA="${ORIGINAL_FASTA%.*}_SD.fasta"
SD_DBG_FILE="${ORIGINAL_FASTA%.*}_SDBG${K_VALUE}_N${N_VALUE}.lz4"
DBG_FILE="${ORIGINAL_FASTA%.*}_DBG${K_VALUE}.lz4"

if [ ! -e "$DBG_FILE" ]; then
  ggcat build --eulertigs -k "$K_VALUE" -j 8 -s 1 "$ORIGINAL_FASTA" -o "$DBG_FILE"
  lz4cat "$DBG_FILE" > "${ORIGINAL_FASTA%.*}_DBG${K_VALUE}"
  seqkit stats "${ORIGINAL_FASTA%.*}_DBG${K_VALUE}" >> "${ORIGINAL_FASTA%.*}_combined_stats.txt"
fi

./superseed.py "$ORIGINAL_FASTA" "$N_VALUE"
ggcat build --eulertigs -k "$K_VALUE" -j 8 -s 1 "$SD_FASTA" -o "$SD_DBG_FILE"
lz4cat "$SD_DBG_FILE" > "${ORIGINAL_FASTA%.*}_SDBG${K_VALUE}_N${N_VALUE}"
seqkit stats "${ORIGINAL_FASTA%.*}_SDBG${K_VALUE}_N${N_VALUE}" >> "${ORIGINAL_FASTA%.*}_stats.txt"

awk '!seen[$0]++' "${ORIGINAL_FASTA%.*}_combined_stats.txt" > "${ORIGINAL_FASTA%.*}_stats_filtered.txt"

