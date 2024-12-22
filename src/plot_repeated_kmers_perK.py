import re
import os
import sys
import pandas as pd
import matplotlib.pyplot as plt

# Validate usage
if len(sys.argv) != 4:
    print("Usage: python script.py <input_file> -k<k_value> <output_file>")
    sys.exit(1)

# Extract input, k, and output arguments
input_file = sys.argv[1]
output_file = sys.argv[3]
k_target = int(sys.argv[2][2:])  # Extract k value from -k<value>

# Extract the base name from the input file for the plot title
file_name = os.path.basename(input_file)
base_name = os.path.splitext(file_name)[0].split("_")[-1]  # Extract the relevant part of the file name

# Initialize a list to store results
data = []

# Read the input file
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
            
            if k_value == k_target:  # Filter for the target k value
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
                                "N": n_value,
                                "Repeated k-mers": repeated_kmers
                            })
else:
    print("No sections found in the file.")
    sys.exit(1)

# Check if data exists for the given k value
if not data:
    print(f"No data found for k={k_target}")
    sys.exit(1)

# Create a DataFrame
df = pd.DataFrame(data)

# Filter only specific N values (1, 2, 4, 8)
df = df[df["N"].isin([1, 2, 4, 8])]

# Get the value for N=1 (if exists)
n1_value = df.loc[df["N"] == 1, "Repeated k-mers"].iloc[0] if not df[df["N"] == 1].empty else None

# Plot repeated k-mers vs N
plt.figure(figsize=(10, 6))

# Plot the curve and points
plt.plot(df["N"], df["Repeated k-mers"], color="#FF1493")
plt.scatter(df["N"], df["Repeated k-mers"], color="#FF1493")

# Add a reference line for N1
if n1_value is not None:
    plt.axhline(y=n1_value, color="gray", linestyle="--", label="Reference line at N=1")

# Customize the plot
plt.xlabel("N")
plt.ylabel("Repeated k-mers")
plt.title(f"{base_name} - k={k_target}")
plt.xticks([1, 2, 3, 4, 5, 6, 7, 8]) 
plt.grid(True)

plt.legend()

# Save the plot as a PNG file
plt.savefig(output_file)

print(f"Graph saved as {output_file}")
