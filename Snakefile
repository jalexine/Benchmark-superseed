import yaml

config = yaml.safe_load(open("config.yaml"))

FASTA_FILES = config["fasta_files"]
N_VALUES = config["n"]
K_VALUES = config["k"]

rule all:
    input:
        # Statistics files for each FASTA
        expand("results/stats_repeatedkmer/rstats_{fasta}.txt", fasta=FASTA_FILES),
        # Superfasta files for each combination of FASTA and N
        expand("results/superfasta/{fasta}_N{n}.fa", fasta=FASTA_FILES, n=N_VALUES),
        # Repeated k-mers plots for each combination of FASTA and K
        expand("results/plots/repeated_kmers_{fasta}.png", fasta=FASTA_FILES),
        # Repeated k-mers plots for each combination of FASTA and K
        expand("results/plots/repeated_kmers_{fasta}_k{k}.png", fasta=FASTA_FILES, k=K_VALUES),
        # SPSS eulertigs
        expand("results/stats_eulertigs/estats.{fasta}.txt", fasta=FASTA_FILES),
        # SPSS eulertigs plots for each combination of FASTA and K
        expand("results/plots/eulertigs_{fasta}_k{k}.png", fasta=FASTA_FILES, k=K_VALUES),



rule superseed:
    input:
        fasta="data/{fasta}.fa"
    output:
        "results/superfasta/{fasta}_N{n}.fa"
    params:
        n="{n}"
    shell:
        """
        mkdir -p results/superfasta  # Ensure the output directory exists
        src/superseed {input.fasta} {params.n} {output}  # Run superseed with input and output
        """

#not efficient here bc we can only 1 core. need to investigate later
rule aggregate_kmc_stats_per_fasta:
    input:
        lambda wildcards: expand("results/superfasta/{fasta}_N{n}.fa", fasta=wildcards.fasta, n=N_VALUES)
    output:
        "results/stats_repeatedkmer/rstats_{fasta}.txt"
    shell:
        """
        mkdir -p results/stats_repeatedkmer
        echo "" > {output}  # Initialize the output file

        # Loop through each value of K
        for k in {config[k]}; do
            echo ">k${{k}}" >> {output}
            
            # Loop through each input file (one per N)
            for file in {input}; do
                # Extract the N value from the filename
                N=$(basename $file | sed 's/.*_N\\([0-9]*\\).fa/\\1/')
                echo "#N${{N}}" >> {output}
                
                # Run KMC for the current K and N values
                ./external/kmc/bin/kmc -k${{k}} -ci2 -fa $file kmc_output . >> {output}
                
                # Clean up temporary KMC files
                rm -f kmc_output.kmc_suf kmc_output.kmc_pre
            done
        done
        """

rule plot_repeated_kmers:
    input:
        stats_file="results/stats_repeatedkmer/rstats_{fasta}.txt"
    output:
        plot="results/plots/repeated_kmers_{fasta}.png"
    params:
        script="src/plot_repeated_kmers.py"
    shell:
        """
        mkdir -p results/plots  # Ensure the output directory exists
        python {params.script} {input.stats_file} {output.plot}
        """

rule plot_repeated_kmers_perK:
    input:
        stats_file="results/stats_repeatedkmer/rstats_{fasta}.txt"
    output:
        plot="results/plots/repeated_kmers_{fasta}_k{k}.png"
    params:
        script="src/plot_repeated_kmers_perK.py",
        k="{k}"
    shell:
        """
        mkdir -p results/plots  # Ensure the output directory exists
        python {params.script} {input.stats_file} -k{params.k} {output.plot}
        """
        
rule stats_eulertigs:
    input:
        superfasta=expand("results/superfasta/{fasta}_N{n}.fa", n=N_VALUES, fasta="{fasta}")
    output:
        stats="results/stats_eulertigs/estats.{fasta}.txt"
    params:
        k_values=config["k"],  # List of k values
        n_values=config["n"],  # List of n values
        threads=8  # Number of threads
    shell:
        """
        mkdir -p results/eulertigs results/stats_eulertigs

        # Initialize the stats file with a clear header
        echo -e "K\tN\tFile\tSize\tNum_seqs\tMin_len\tAvg_len\tMax_len" > {output.stats}

        # Loop through each combination of k and n
        for k in {params.k_values}; do
            for n in {params.n_values}; do
                # Define the temporary eulertigs file
                eulertigs_file="results/eulertigs/{wildcards.fasta}_k${{k}}_N${{n}}.fa"

                # Remove any existing file to avoid conflicts
                rm -f $eulertigs_file

                # Run ggcat
                echo "Running: ggcat build --eulertigs -k $k -j {params.threads} results/superfasta/{wildcards.fasta}_N${{n}}.fa -o $eulertigs_file" >> debug.log
                ggcat build --eulertigs -k $k -j {params.threads} results/superfasta/{wildcards.fasta}_N${{n}}.fa -o $eulertigs_file

                # Add the stats to the output file
                seqkit stats $eulertigs_file | tail -n +2 | awk -v N=$n -v K=$k '{{print K"\t"N"\t"$0}}' >> {output.stats}
            done
        done

        # clean up temporary eulertigs files after processing
        rm -rf results/eulertigs
        """

rule plot_eurlitigs:
    input:
        stats_file="results/stats_eulertigs/estats.{fasta}.txt"
    output:
        plot="results/plots/eulertigs_{fasta}_k{k}.png"
    params:
        script="src/plot_eulertigs_perK.py",
        k="{k}"
    shell:
        """
        mkdir -p results/plots  # Ensure the output directory exists
        python {params.script} {input.stats_file} -k{params.k} {output.plot}
        """