#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo -e "\033[95m♡Pls use: $0 <original.fasta> <another.fasta>\033[0m"
    exit 1
fi

fastapath1="$1"
fastapath2="$2"

./KMC3.2/bin/kmc -k31 -ci1 -fa "$fastapath1" kmc_O1 .
./KMC3.2/bin/kmc -k31 -ci1 -fa "$fastapath2" kmc_O2 .

./KMC3.2/bin/kmc_tools simple kmc_O1 kmc_O2 intersect inter

./KMC3.2/bin/kmc_dump inter kmcoutput.txt

wc -l kmcoutput.txt

