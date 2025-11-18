# nf-fastqc

A simple, portable FastQC pipeline using **Nextflow**.  
Supports both **local (Docker)** and **HPC (Slurm + Singularity)** execution.

---

## 📁 Demo data

```

mkdir -p ~/nf-fastqc/test_data
cd test_data

wget https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR155/007/SRR1553607/SRR1553607_1.fastq.gz
wget https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR155/007/SRR1553607/SRR1553607_2.fastq.gz

```

---

## 🚀 Run locally (Docker)

```

nextflow run main.nf -profile local

```

Requirements:
- Nextflow
- Fastqc image `docker pull biocontainers/fastqc:v0.11.9_cv8`
- `configs/local.config`

---

## 🚀 Run on HPC (Slurm + Singularity)

```

nextflow run main.nf -profile hpc

```

Requirements:
- Slurm scheduler
- Singularity available
- FastQC `.sif` at: `$HOME/singularity_image/fastqc-0.11.9.sif`
- `configs/slurm.config` 

Output is written to:

```

fastqc_output/

```

---

## 📂 Project structure

```

main.nf
nextflow.config
configs/
├── local.config      # local + Docker
└── slurm.config      # HPC + Slurm + Singularity
test_data/               # optional demo data

```

---

## ✔️ What this pipeline does

- Runs FastQC on all `*.fastq.gz` files  
- Skips samples already processed  
- Publishes results to `fastqc_output/`  
- Works identically on local and HPC environments  

---
