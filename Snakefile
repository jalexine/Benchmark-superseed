import yaml

config = yaml.safe_load(open("config.yaml"))

FASTA_LIST = [config["fasta1"], config["fasta2"], config["fasta3"]]
fasta1= [config['fasta1']]
fasta2= [config['fasta2']]

n_values = range(2, 11)
output_dir = "output/data"

rule all:
    input:
        expand(f"{output_dir}/{{fasta}}_sum_len_plot.png", fasta=FASTA_LIST)

rule superseeds:
    input:
        fasta="data/{fasta}.fa"
    output:
        expand(f"{output_dir}/{{fasta}}_N{{n}}.fa", fasta="{fasta}", n=n_values)
    params:
        dif_script="./difvalues.sh"
    conda:
        "environment.yml"
    shell:
        """
        mkdir -p {output_dir}
        {params.dif_script} {input.fasta}
        mv data/{wildcards.fasta}_N*.fa {output_dir}/
        """

rule kmc_intersect:
    input:
        [f"data/{fasta1}.fa", f"data/{fasta2}.fa"] + expand(f"{output_dir}/{{fasta}}_N{{n}}.fa", fasta=[fasta1, fasta2], n=n_values)
    output:
        f"{output_dir}/kmcoutput_{fasta1}_{fasta2}.txt"
    params:
        kmc_path="./KMC3.2/bin/"
    conda:
        "environment.yml"
    shell:
        """
        mkdir -p {output_dir}
        {params.kmc_path}kmc -k31 -ci1 -fa {input[0]} kmc_O1 .
        {params.kmc_path}kmc -k31 -ci1 -fa {input[1]} kmc_O2 .
        {params.kmc_path}kmc_tools simple kmc_O1 kmc_O2 intersect inter
        {params.kmc_path}kmc_dump inter {output}
        rm kmc_O1.kmc_pre kmc_O1.kmc_suf kmc_O2.kmc_pre kmc_O2.kmc_suf inter.kmc_pre inter.kmc_suf
        """

rule summary_commonkmer:
    input:
        f"output/data/kmcoutput_{fasta1}_{fasta2}.txt",  
        expand(f"{output_dir}/kmcoutput_{{fasta1}}_{{fasta2}}_N{{n}}.txt", fasta1=fasta1, fasta2=fasta2, n=n_values),
    output:
        f"summary_{fasta1}_{fasta2}.txt"
    conda:
        "environment.yml"
    shell:
        """
        echo "Summary of KMC output line counts:" > {output}
        for file in {input}; do
            wc -l $file >> {output}
        done
        """

rule plot_commonkmer:
    input:
        summary=f"summary_{fasta1}_{fasta2}.txt"
    output:
        plot=f"output/plots/{fasta1}_{fasta2}_commonkmer_plot.png"
    conda:
        "environment.yml"
    shell:
        "python plot_commonkmer.py {input.summary} {output.plot}"

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
        [f"data/{fasta1}.fa", f"data/{fasta2}.fa"]+ expand(f"{output_dir}/{{fasta}}_N{{n}}.fa", fasta=[fasta1, fasta2], n=n_values) 
    output:
        f"{output_dir}/repeatedkmer_{fasta1}.txt",
        f"{output_dir}/repeatedkmer_{fasta2}.txt"
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
        stats1=f"{output_dir}/repeatedkmer_{fasta1}.txt",
        stats2=f"{output_dir}/repeatedkmer_{fasta2}.txt"
    output:
        f"output/plots/{fasta1}_repeatedkmer_plot.png",
        f"output/plots/{fasta2}_repeatedkmer_plot.png"
    conda:
        "environment.yml"
    shell:
        """
        python plot_repeatedkmer.py {input.stats1} {input.stats2} {output[0]} {output[1]}

        """
