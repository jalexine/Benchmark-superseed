import yaml

config = yaml.safe_load(open("config.yaml"))
N_VALUES = [1, 2, 4, 8] 
FASTA_LIST = ["test"]
#FASTA_LIST = [config["fasta1"], config["fasta2"], config["fasta3"]]
fasta1= [config['fasta1']]
fasta2= [config['fasta2']]

n_values = range(2, 11)
output_dir = "output/data"

rule all:
    input:
        expand("data/output/{fasta}_N{n}.fa", fasta=FASTA_LIST, n=N_VALUES)

rule superseeds:
    input:
        fasta="data/{fasta}.fa"
    output:
        "{output_dir}/{fasta}_N{n}.fa"
    params:
        seed_executable="bin/superseed" 
    shell:
        """
        mkdir -p {output_dir}
        {params.seed_executable} {input.fasta} {wildcards.n} > {output}
        """
        
rule sumlen_ggcat:
    input:
        fasta=[f"data/{{fasta}}.fa"] + expand(f"{output_dir}/{{fasta}}_N{{n}}.fa", fasta="{fasta}", n=n_values)
    output:
        stats=f"{output_dir}/{{fasta}}_stats.txt"
    params:
        k_value=31
    conda:
        "environment.yml"
    shell:
        """
        > {output.stats}
        for fasta in {input}; do
            ./ggcat.sh {params.k_value} $fasta {output.stats}
        done
        """

rule plot_sumlen_ggcat:
    input:
        stats=f"{output_dir}/{{fasta}}_stats.txt"
    output:
        plot=f"{output_dir}/{{fasta}}_sum_len_plot.png"
    conda:
        "environment.yml"
    shell:
        """
        python plotggcat.py {input.stats} {output.plot}
        """

rule kmc_repeatedkmer:
    input:
        fasta=[f"data/{{fasta}}.fa"] + expand(f"{output_dir}/{{fasta}}_N{{n}}.fa", fasta="{fasta}", n=n_values)
    output:
        stats=f"{output_dir}/repeatedkmer_{{fasta}}.txt"
    params:
        kmc_path="./KMC3.2/bin/",
        python_script="repeatedkmer.py"
    conda:
        "environment.yml"
    shell:
        """
        # Process each fasta file and append to the corresponding output file
        for fasta in {input}; do
            output_file="{output_dir}/repeatedkmer_$(basename ${{fasta}} .fa | cut -d'_' -f1).txt"
            python {params.python_script} ${{fasta}} ${{output_file}}
        done
        """

rule plot_repeated_kmers:
    input:
        stats=f"{output_dir}/repeatedkmer_{{fasta}}.txt"
    output:
        plot=f"output/plots/{{fasta}}_repeatedkmer_plot.png",
    conda:
        "environment.yml"
    shell:
        """
        python plot_repeatedkmer.py {input.stats} {output.plot} 
        """
