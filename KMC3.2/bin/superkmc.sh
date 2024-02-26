#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 output1 output2"
    exit 1
fi

output1="$1"
output2="$2"

path_kmc="/Users/alexine/chaosmer/KMC3.2/bin/kmc"
$path_kmc -k21 "$output1" "$output1" "/Users/alexine/chaosmer/"
$path_kmc -k21 "$output2" "$output2" "/Users/alexine/chaosmer/"

#path_kmc_tools="/Users/alexine/chaosmer/KMC3.2/bin/kmc_tools"
#$path_kmc_tools intersect "$output1.kmc" "$output2.kmc" "$output1"_"$output2"_intersect

#$path_kmc_tools intersect "$output1"_kmc -ci10 -cx200 "$output2"_kmc -ci4 -cx100 "$output1"_"$output2"_intersect -ci20 -cx150

