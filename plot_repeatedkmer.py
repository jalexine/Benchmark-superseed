import sys
import pandas as pd
import matplotlib.pyplot as plt

def plot_repeated_kmers(file1, file2, output_dir):
    # Read the files
    df1 = pd.read_csv(file1, header=None, names=['file', 'count'])
    df2 = pd.read_csv(file2, header=None, names=['file', 'count'])

    # Plot the data
    plt.figure(figsize=(10, 6))

    # Plot the data points with markers, but start plotting from the second point
    plt.plot(df1.index + 1, df1['count'], label=f'{file1}', color='#FF69B4')
    plt.plot(df1.index[1:] + 1, df1['count'][1:], marker='o', label='_nolegend_', color='#FF69B4')
    plt.plot(df2.index + 1, df2['count'], label=f'{file2}', color='purple')
    plt.plot(df2.index[1:] + 1, df2['count'][1:], marker='o', label='_nolegend_', color='purple')

    plt.xlabel('N Values')
    plt.ylabel('Repeated k-mers for Different N')
    plt.title('Repeated k-mers vs N')
    plt.legend()
    plt.grid(True)

    # Set x-axis limits to start from 1
    plt.xlim(1, max(len(df1), len(df2)))

    # Save the plots
    output_file1 = f"{output_dir}/{file1.split('/')[-1].replace('.txt', '_plot.png')}"
    output_file2 = f"{output_dir}/{file2.split('/')[-1].replace('.txt', '_plot.png')}"

    plt.savefig(output_file1)
    plt.savefig(output_file2)
    plt.show()

if __name__ == "__main__":
    file1 = sys.argv[1]
    file2 = sys.argv[2]
    output_dir = sys.argv[3]
    plot_repeated_kmers(file1, file2, output_dir)
