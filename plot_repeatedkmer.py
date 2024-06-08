import sys
import pandas as pd
import matplotlib.pyplot as plt

def plot_repeated_kmers(file, output_file):
    df = pd.read_csv(file, header=None, names=['file', 'count'])

    # Extract the meaningful part of the filename
    title = file.split('/')[-1].replace('repeatedkmer_', '').replace('.txt', '')

    plt.figure(figsize=(10, 6))

    plt.plot(df.index + 1, df['count'], color='#FF69B4')
    plt.plot(df.index[1:] + 1, df['count'][1:], marker='o', color='#FF69B4')

    plt.xlabel('N Values')
    plt.ylabel('Repeated k-mers')
    plt.title(f'Repeated k-mers vs N for {title}')
    plt.grid(True)

    plt.xlim(1, len(df))

    plt.savefig(output_file)
    plt.close()

if __name__ == "__main__":
    file1 = sys.argv[1]
    file2 = sys.argv[2]
    output_file1 = sys.argv[3]
    output_file2 = sys.argv[4]

    plot_repeated_kmers(file1, output_file1)
    plot_repeated_kmers(file2, output_file2)
