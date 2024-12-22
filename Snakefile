import yaml

config = yaml.safe_load(open("config.yaml"))

FASTA_FILES = config["fasta_files"]
N_VALUES = config["n"]


rule all:
    input:
        expand("results/{fasta}_N{n}.fa", fasta=FASTA_FILES, n=N_VALUES)

rule superseed:
    input:
        fasta="data/{fasta}.fa"  
    output:
        "results/{fasta}_N{n}.fa"
    params:
        n="{n}"
    shell:
        """
        mkdir -p results
        src/superseed {input.fasta} {params.n} {output}
        """
