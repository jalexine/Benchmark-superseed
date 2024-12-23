import matplotlib.pyplot as plt
import argparse
import os

# Argument parser
parser = argparse.ArgumentParser(description="Plot sum length vs N for a specific k value.")
parser.add_argument("input_file", help="Path to the input file.")
parser.add_argument("-k", type=int, required=True, help="Value of k to filter.")
parser.add_argument("output_file", help="Path to save the output plot.")

args = parser.parse_args()
file_path = args.input_file
k_value = args.k
output_file = args.output_file

# Extract the base name of the file 
file_name = os.path.basename(file_path)
title_name = file_name.split(".")[1] 

# Initialize lists to store data
N_values = []
sum_lengths = []

# Read and extract data
with open(file_path, "r") as file:
    for line in file:
        if line.strip() and not line.startswith("K"):  # Skip headers
            parts = line.split()  # Split the line
            k = int(parts[0])  # Extract K
            if k == k_value:  # Filter for the specific k value
                N = int(parts[1])  # Extract N
                sum_length = int(parts[6].replace(",", ""))  # Extract and parse sum_length
                N_values.append(N)
                sum_lengths.append(sum_length)

# Reference value for the horizontal line (sum_length for N = 1)
horizontal_reference = sum_lengths[0] if N_values and N_values[0] == 1 else 0

# Plot the graph
plt.figure(figsize=(8, 6))
plt.plot(N_values, sum_lengths, marker="o", linestyle="-", color="#FF1493")
plt.axhline(y=horizontal_reference, color="gray", linestyle="--", label="Reference line at N = 1")
plt.xlabel("N")
plt.ylabel("Sum Length")
plt.title(f"{title_name} - k = {k_value}")
plt.grid(True)
plt.ticklabel_format(axis="y", style="plain")
plt.legend()
plt.savefig(output_file)
print(f"Plot saved to {output_file}")
