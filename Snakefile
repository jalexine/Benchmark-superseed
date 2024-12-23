import yaml

config = yaml.safe_load(open("config.yaml"))

FASTA_FILES = config["fasta_files"]
N_VALUES = config["n"]
K_VALUES = config["k"]

rule all:
    input:
        # Superfasta files for each combination of FASTA and N
        expand("results/superfasta/{fasta}_N{n}.fa", fasta=FASTA_FILES, n=N_VALUES),
        # Repeated Kmer KMC
        expand("results/repeatedkmers/{fasta}_N{n}_k{k}_repeated.txt", fasta=FASTA_FILES, n=N_VALUES, k=K_VALUES),
        # Plot repeated Kmer KMC
        expand("results/plots/{fasta}_repeated_kmers.png", fasta=FASTA_FILES),
        # SPSS eulertigs ggcat
        expand("results/stats_eulertigs/estats.{fasta}.txt", fasta=FASTA_FILES),
        #Plot eulertigs ggcat
        expand("results/plots/{fasta}_eulertigs.png", fasta=FASTA_FILES),


        
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
rule kmc_process:
    input:
        fasta="results/superfasta/{fasta}_N{n}.fa"
    output:
        repeated_kmers="results/repeatedkmers/{fasta}_N{n}_k{k}_repeated.txt"
    params:
        k="{k}"
    shell:
        """
        mkdir -p results/tmp_kmc_dir results/repeatedkmers

        # Run KMC
        ./external/kmc/bin/kmc -k{params.k} -ci2 -fa {input.fasta} \
            results/tmp_kmc_dir/kmc_output_{wildcards.fasta}_N{wildcards.n}_k{wildcards.k} .

        # Export k-mers with KMC tools
        ./external/kmc/bin/kmc_tools transform \
            results/tmp_kmc_dir/kmc_output_{wildcards.fasta}_N{wildcards.n}_k{wildcards.k} dump \
            results/tmp_kmc_dir/kmc_dump_{wildcards.fasta}_N{wildcards.n}_k{wildcards.k}.txt

        # Filter with awk to keep only repeated k-mers
        awk '$2 >= 2' results/tmp_kmc_dir/kmc_dump_{wildcards.fasta}_N{wildcards.n}_k{wildcards.k}.txt > {output}

        # Clean up intermediate files
        rm -f results/tmp_kmc_dir/kmc_dump_{wildcards.fasta}_N{wildcards.n}_k{wildcards.k}.txt
        rm -rf results/tmp_kmc_dir
        """

rule plot_repeated_kmers:
    input:
        txt_files=lambda wildcards: expand(
            "results/repeatedkmers/{fasta}_N{n}_k{k}_repeated.txt", 
            fasta=[wildcards.fasta], 
            n=N_VALUES, 
            k=K_VALUES
        )
    output:
        png="results/plots/{fasta}_repeated_kmers.png"
    shell:
        """
        mkdir -p results/plots
        python src/plot_repeated_kmers.py {input.txt_files} {output.png}
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

rule plot_eulertigs:
    input:
        stats="results/stats_eulertigs/estats.{fasta}.txt"
    output:
        plot="results/plots/{fasta}_eulertigs.png"
    params:
        k_values=config["k"],
        n_values=config["n"]
    shell:
        """
        mkdir -p results/plots

        # Run the plotting script
        python src/plot_eulertigs.py {input.stats} {output.plot}
        """
