import pandas as pd
import matplotlib.pyplot as plt
import os

def read_data(filename):
    data = []
    with open(filename, 'r') as file:
        for line in file:
            if line.strip() and not line.startswith('file'):
                parts = line.split()
                data.append({
                    'sum_len': int(parts[4].replace(',', ''))
                })
    df = pd.DataFrame(data)
    df['N'] = range(1, len(df) + 1)
    return df

def plot_sum_len(df, fasta_name, output_file):
    plt.figure(figsize=(10, 6))
    plt.plot(df['N'], df['sum_len'], marker='', linestyle='-', color='#FF69B4') 
    plt.plot(df['N'][1:], df['sum_len'][1:], marker='o', linestyle='-', color='#FF69B4')  
    
    plt.axhline(y=df['sum_len'][0], color='purple', linestyle='--', label='Reference Line at N=1')
    
    plt.xlabel('N')
    plt.ylabel('sum_len')
    plt.title(f'Total Sequence Length (sum_len) Across Different N for the {fasta_name} Samples')
    plt.grid(True)
    plt.xticks(df['N'])
    plt.xlim(1, len(df) + 0)
    plt.legend()
    plt.savefig(output_file)
    plt.close()

def main(fasta_stats_file, output_dir):
    df = read_data(fasta_stats_file)
    fasta_name = os.path.splitext(os.path.basename(fasta_stats_file))[0]

    plot_sum_len(df, fasta_name, os.path.join(output_dir, f'{fasta_name}_sum_len_plot.png'))

if __name__ == '__main__':
    import sys
    if len(sys.argv) != 3:
        print("Usage: python plotggcat.py <fasta_stats_file> <output_dir>")
        sys.exit(1)

    fasta_stats_file = sys.argv[1]
    output_dir = sys.argv[2]

    os.makedirs(output_dir, exist_ok=True)
    main(fasta_stats_file, output_dir)
