import matplotlib.pyplot as plt

file_path = 'summary.txt'
data = []

with open(file_path, 'r') as file:
    for line in file:
        parts = line.split()
        if len(parts) == 2 and parts[0].isdigit():
            count = int(parts[0])
            filename = parts[1]
            data.append((filename, count))

n_values = []
counts = []

for filename, count in data:
    if "N" in filename:
        n = int(filename.split("_N")[1].split(".txt")[0])
        n_values.append(n)
        counts.append(count)

sorted_data = sorted(zip(n_values, counts))
n_values_sorted, counts_sorted = zip(*sorted_data)

plt.figure(figsize=(10, 6))
plt.plot(n_values_sorted, counts_sorted, 'o-', color='pink', markersize=8, linewidth=2)

plt.title('Common k-mers for Different N Values', fontsize=14)
plt.xlabel('N Values', fontsize=12)
plt.ylabel('Number of Common k-mers', fontsize=12)
plt.grid(True)
plt.show()
