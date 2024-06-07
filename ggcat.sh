#!/bin/bash

K_VALUE=$1
fasta=$2
statsfile=$3

# Exécute ggcat
ggcat build --generate-maximal-unitigs-links -k "$K_VALUE" -j 8 -s 2 "$fasta" -o "outputfasta.fa"

# Remplace "outputfasta.fa" par le nom du fichier d'entrée dans les statistiques
seqkit stats "outputfasta.fa" | sed "s/outputfasta.fa/$(basename $fasta)/" >> "$statsfile"

