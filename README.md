# nf-fastqc


nf-fastqc/
  ├── main.nf
  ├── nextflow.config
  └── modules/
      └── fastqc.nf


```
mkdir ~/singularity_images
cd ~/singularity_images

singularity pull fastqc-0.11.9.sif docker://biocontainers/fastqc:v0.11.9_cv8

```