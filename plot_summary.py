import sys
import matplotlib.pyplot as plt
import os

def read_data(file_path):
    n_values = []
    counts = []
    with open(file_path, 'r') as file:
        next(file) 
        for idx, line in enumerate(file, start=1):
            parts = line.split()
            count = int(parts[0])
            counts.append(count)
            n_values.append(idx)
    return n_values, counts

def plot_data(n_values, counts, fasta_name, output_plot_path):
    plt.figure(figsize=(10, 6))
    plt.plot(n_values, counts, linestyle='-', color='#FF69B4', linewidth=2)
    plt.plot(n_values[1:], counts[1:], 'o', linestyle='', color='#FF69B4', markersize=8)
    plt.axhline(y=counts[0], color='purple', linestyle='--', label='Reference Line at N=1')
    
    plt.title(f'Common k-mers for Different N for the {fasta_name}', fontsize=14)
    plt.xlabel('N Values', fontsize=12)
    plt.ylabel('Number of Common k-mers', fontsize=12)
    plt.grid(True)
    plt.legend()
    
    plt.xticks(range(0, len(n_values) + 1))
    plt.xlim(1, len(n_values) + 0)
    
    plt.savefig(output_plot_path)
    plt.close()

def main():
    if len(sys.argv) != 3:
        print("Usage: python my_plot_script.py <input_file> <output_plot_path>")
        sys.exit(1)

    file_path = sys.argv[1]
    output_plot_path = sys.argv[2]

    fasta_parts = os.path.basename(file_path).split('.')[0].split('_')
    fasta_name = '_'.join(fasta_parts[1:])
    
    n_values, counts = read_data(file_path)
    plot_data(n_values, counts, fasta_name, output_plot_path)

if __name__ == '__main__':
    main()
