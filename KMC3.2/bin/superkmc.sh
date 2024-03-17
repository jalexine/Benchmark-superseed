#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "U\033[95m♡Pls use: $0 output1 output2 \033[0m"
    exit 1
fi

output1="$1"
output2="$2"

if [ ! -f "$output1" ] || [ ! -f "$output2" ]; then
    echo "files pb"
    exit 1
fi

path_kmc="/Users/alexine/chaosmer/KMC3.2/bin/kmc"
$path_kmc -k21 -ci1 -cs1000 "$output1" "$output1.kmc"
$path_kmc -k21 -ci1 -cs1000 "$output2" "$output2.kmc"

#path_kmc_tools="/Users/alexine/chaosmer/KMC3.2/bin/kmc_tools"
#$path_kmc_tools intersect "$output1.kmc" "$output2.kmc" "$output1"_"$output2"_intersect

