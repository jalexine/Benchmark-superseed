#!/bin/bash

fastapath="$1"
input_name="$(basename -- "$fastapath" .fa)"

python3 superseed.py "$fastapath" 2 > "${input_name}_N2.fa"

./KMC3.2/bin/kmc -k31 -fa "$fastapath" kmc_O1 .
./KMC3.2/bin/kmc -k31 -fa "${input_name}_N2.fa" kmc_O2 .

./KMC3.2/bin/kmc_tools simple kmc_O1 kmc_O2 intersect inter

./KMC3.2/bin/kmc_dump inter kmcoutput.txt

wc -l kmcoutput.txt

