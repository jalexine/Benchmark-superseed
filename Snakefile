import yaml

config = yaml.safe_load(open("config.yaml"))

fasta1 = config["fasta1"]
fasta2 = config["fasta2"]
n_values = range(2, 11)
output_dir = "output/data"

rule all:
    input:
        expand(f"{output_dir}/{{fasta1}}_N{{n}}.fa", fasta1=fasta1, n=n_values),
        expand(f"{output_dir}/{{fasta2}}_N{{n}}.fa", fasta2=fasta2, n=n_values),
        f"output/plots/{fasta1}_sum_len_plot.png",
        f"output/plots/{fasta2}_sum_len_plot.png",
        f"summary_{fasta1}_{fasta2}.txt",
        f"output/plots/commonkmer_{fasta1}_{fasta2}_plot.png"

rule generate_seeds:
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

rule process_kmc:
    input:
        fasta1=f"{output_dir}/{{fasta1}}_N{{n}}.fa",
        fasta2=f"{output_dir}/{{fasta2}}_N{{n}}.fa"
    output:
        f"{output_dir}/kmcoutput_{{fasta1}}_{{fasta2}}_N{{n}}.txt"
    params:
        kmc_path="./KMC3.2/bin/"
    conda:
        "environment.yml"
    shell:
        """
        {params.kmc_path}kmc -k31 -ci1 -fa {input.fasta1} kmc_O1 .
        {params.kmc_path}kmc -k31 -ci1 -fa {input.fasta2} kmc_O2 .
        {params.kmc_path}kmc_tools simple kmc_O1 kmc_O2 intersect inter
        {params.kmc_path}kmc_dump inter {output}
        rm kmc_O1.kmc_pre kmc_O1.kmc_suf kmc_O2.kmc_pre kmc_O2.kmc_suf inter.kmc_pre inter.kmc_suf
        """

rule process_kmc_original:
    input:
        fasta1=f"data/{fasta1}.fa",
        fasta2=f"data/{fasta2}.fa"
    output:
        f"{output_dir}/kmcoutput_{fasta1}_{fasta2}.txt"
    params:
        kmc_path="./KMC3.2/bin/"
    conda:
        "environment.yml"
    shell:
        """
        mkdir -p {output_dir}
        {params.kmc_path}kmc -k31 -ci1 -fa {input.fasta1} kmc_O1 .
        {params.kmc_path}kmc -k31 -ci1 -fa {input.fasta2} kmc_O2 .
        {params.kmc_path}kmc_tools simple kmc_O1 kmc_O2 intersect inter
        {params.kmc_path}kmc_dump inter {output}
        rm kmc_O1.kmc_pre kmc_O1.kmc_suf kmc_O2.kmc_pre kmc_O2.kmc_suf inter.kmc_pre inter.kmc_suf
        """

rule generate_summary:
    input:
        f"output/data/kmcoutput_{fasta1}_{fasta2}.txt",  # Ajoutez manuellement cette entrée
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

rule plot_summary:
    input:
        summary=f"summary_{fasta1}_{fasta2}.txt"
    output:
        plot=f"output/plots/commonkmer_{fasta1}_{fasta2}_plot.png"
    conda:
        "environment.yml"
    shell:
        "python plot_commonkmer.py {input.summary} {output.plot}"



rule run_ggcat_fasta1:
    input:
        fasta=[f"data/{fasta1}.fa"] + expand(f"{output_dir}/{{fasta}}_N{{n}}.fa", fasta=fasta1, n=n_values)
    output:
        stats=f"{output_dir}/{fasta1}_stats.txt"
    params:
        k_value=31
    conda:
        "environment.yml"
    shell:
        """
        > {output.stats}
        for fasta in {input.fasta}; do
            ./ggcat.sh {params.k_value} $fasta {output.stats}
        done
        """

rule run_ggcat_fasta2:
    input:
        fasta=[f"data/{fasta2}.fa"] + expand(f"{output_dir}/{{fasta}}_N{{n}}.fa", fasta=fasta2, n=n_values)
    output:
        stats=f"{output_dir}/{fasta2}_stats.txt"
    params:
        k_value=31
    conda:
        "environment.yml"
    shell:
        """
        > {output.stats}
        for fasta in {input.fasta}; do
            ./ggcat.sh {params.k_value} $fasta {output.stats}
        done
        """

rule plot_stats_sum_len:
    input:
        stats1=f"{output_dir}/{fasta1}_stats.txt",
        stats2=f"{output_dir}/{fasta2}_stats.txt"
    output:
        f"output/plots/{fasta1}_sum_len_plot.png",
        f"output/plots/{fasta2}_sum_len_plot.png"
    conda:
        "environment.yml"
    shell:
        """
        python plotggcat.py {input.stats1} {input.stats2} output/plots
        """

