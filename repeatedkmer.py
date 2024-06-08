import subprocess
import os
import sys

def run_kmc(fasta_file, output_file):
    cmd = f"./KMC3.2/bin/kmc -k31 -ci2 -fa {fasta_file} kmc1 ."
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    unique_kmers = "0"
    for line in result.stdout.splitlines():
        if "No. of unique counted k-mers" in line:
            unique_kmers = line.split(":")[1].strip()
            break
    with open(output_file, "a") as file:
        file.write(f"{os.path.basename(fasta_file)},{unique_kmers}\n")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python run_kmc.py <fasta_file> <output_file>")
        sys.exit(1)

    fasta_file = sys.argv[1]
    output_file = sys.argv[2]
    run_kmc(fasta_file, output_file)