TOOLS_DIR = external
KMC_DIR = $(TOOLS_DIR)/kmc
SEQKIT_BIN = $(TOOLS_DIR)/seqkit/seqkit
GGCAT_BIN = $(TOOLS_DIR)/ggcat/ggcat

.PHONY: all install tools kmc ggcat seqkit clean

all: install

install: tools
	@echo "All tools installed. You can now run 'snakemake --cores 1'."

tools: kmc ggcat seqkit

kmc:
	@echo "Installing KMC..."
	git submodule update --init --recursive
	$(MAKE) -C $(KMC_DIR)

ggcat:
	@echo "Installing GGCAT via Conda..."
	conda install -y -c conda-forge -c bioconda ggcat

seqkit:
	@echo "Installing SeqKit..."
	curl -LO https://github.com/shenwei356/seqkit/releases/download/v2.3.1/seqkit_linux_amd64.tar.gz
	tar -xzf seqkit_linux_amd64.tar.gz
	mkdir -p $(TOOLS_DIR)/seqkit
	mv seqkit $(SEQKIT_BIN)
	rm -f seqkit_linux_amd64.tar.gz


clean:
	@echo "Cleaning up tools..."
	rm -rf $(TOOLS_DIR)/kmc/bin $(TOOLS_DIR)/seqkit
	conda remove -y ggcat || true

