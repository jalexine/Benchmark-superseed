import re
import os
import sys
import pandas as pd
import matplotlib.pyplot as plt

# Check for correct usage
if len(sys.argv) != 3:
    print("Usage: python script_name.py <input_file> <output_file>")
    sys.exit(1)

# Get input and output file paths from command line arguments
input_file = sys.argv[1]
output_file = sys.argv[2]

# Extract the base name from the input file for the plot title
file_name = os.path.basename(input_file)
base_name = os.path.splitext(file_name)[0].split("_")[-1]  # Extracts the relevant part of the file name

# Initialize a list to store results
data = []

# Open and read the input file
with open(input_file, "r") as file:
    content = file.read()

# Split content into sections starting with ">kXX"
k_sections = re.split(r"(?=>k\d+)", content)

if k_sections:
    print("Extracting repeated k-mers for each k and N...\n")
    for k_section in k_sections:
        # Match the `k` value (e.g., k21, k31)
        k_match = re.match(r">k(\d+)", k_section)
        if k_match:
            k_value = int(k_match.group(1))  # k value as an integer
            
            # Find all `#N` blocks within the section
            n_blocks = re.split(r"(?=#N\d+)", k_section)
            for n_block in n_blocks:
                n_match = re.match(r"#N(\d+)", n_block)
                if n_match:
                    n_value = int(n_match.group(1))  # N value as an integer
                    
                    # Extract stats from the block
                    unique_kmers_match = re.search(r"No\. of unique k-mers\s+:\s+(\d+)", n_block)
                    total_kmers_match = re.search(r"Total no\. of k-mers\s+:\s+(\d+)", n_block)
                    
                    if unique_kmers_match and total_kmers_match:
                        unique_kmers = int(unique_kmers_match.group(1))
                        total_kmers = int(total_kmers_match.group(1))
                        repeated_kmers = total_kmers - unique_kmers
                        
                        # Append data to the list
                        data.append({
                            "k": k_value,
                            "N": n_value,
                            "Repeated k-mers": repeated_kmers
                        })
else:
    print("No sections found in the file.")
    sys.exit(1)

# Create a DataFrame
df = pd.DataFrame(data)

# Plot repeated k-mers vs k for each N
plt.figure(figsize=(10, 6))

for n_value in df["N"].unique():
    subset = df[df["N"] == n_value]
    # Plot the curve
    plt.plot(subset["k"], subset["Repeated k-mers"], label=f"N{n_value}")
    # Add points
    plt.scatter(subset["k"], subset["Repeated k-mers"])

# Set x-axis ticks (specific k values)
plt.xticks(sorted(df["k"].unique()))  # Show only k values present in the data

plt.xlabel("k")
plt.ylabel("Repeated k-mers")
plt.title(f"{base_name}")
plt.legend(title="N values")
plt.grid(True)

# Save the plot as a PNG file
plt.savefig(output_file)


print(f"Graph saved as {output_file}")
