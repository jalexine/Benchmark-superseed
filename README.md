# Benchmark-superseed

description soon

---

## Requirements

### Snakemake

To install Snakemake, run the following command:
```bash
pip install snakemake
```

### 2. KMC
Compilation Instructions

1. Clone the repository with its submodules:
   ```bash
   git clone --recurse-submodules git@github.com:jalexine/Benchmark-superseed.git
   cd Benchmark-superseed
   ```

2. Navigate to the KMC directory:
   ```bash
   cd external/kmc
   ```

3. Compile KMC:
   ```bash
   make -j32
   ```

4. Verify that the binary `kmc` is available in `external/kmc/bin/`.

---
