# nf-fastqc

`nf-fastqc` runs FastQC on raw FASTQ files and saves the standard FastQC HTML and ZIP reports.

This module is usually the first QC step in the ChIP-seq pipeline.

## What It Does

1. Finds input FASTQ files.
2. Skips files that already have both FastQC outputs.
3. Runs `fastqc`.
4. Saves results to the selected output folder.

The two standard output files are:

- `*_fastqc.html`: human-readable QC report
- `*_fastqc.zip`: FastQC raw result archive, useful for MultiQC

## Before You Run

You need:

- Nextflow installed
- Access to the FASTQ files
- For local runs: Docker available
- For HPC runs: Slurm and Singularity available
- For HPC runs: the FastQC Singularity image path in `configs/slurm.config` must exist

Default HPC notification email:

```text
molendo.hpc@gmail.com
```

## Input Options

There are two ways to provide FASTQ files.

### Option 1: Samples Master CSV Recommended

Use this when running the full ChIP-seq pipeline or when you have multiple samples.

The CSV should contain these columns:

```csv
sample_id,fastq_r1,fastq_r2,enabled
WT_rep1,/path/to/WT_rep1_R1.fastq.gz,/path/to/WT_rep1_R2.fastq.gz,true
WT_rep2,/path/to/WT_rep2_R1.fastq.gz,/path/to/WT_rep2_R2.fastq.gz,true
```

Notes:

- `fastq_r1` is required for single-end or paired-end data.
- `fastq_r2` is used for paired-end data and can be empty for single-end data.
- Rows with `enabled=false` are skipped.
- Empty `enabled` values are treated as enabled.

Run with:

```bash
nextflow run main.nf -profile hpc \
  --samples_master /path/to/samples_master.csv \
  --project_folder /path/to/output_project \
  --fastqc_output fastqc_output
```

### Option 2: FASTQ Folder + Pattern

Use this for quick module testing.

```bash
nextflow run main.nf -profile hpc \
  --fastqc_raw_data /path/to/fastq_folder \
  --fastqc_pattern "*fastq.gz" \
  --project_folder /path/to/output_project \
  --fastqc_output fastqc_output
```

If neither `--samples_master` nor `--fastqc_raw_data` is provided, the module stops with an error.

## Output

Results are written to:

```text
${project_folder}/${fastqc_output}/
```

Example:

```text
/path/to/output_project/fastqc_output/
  WT_rep1_R1_fastqc.html
  WT_rep1_R1_fastqc.zip
  WT_rep1_R2_fastqc.html
  WT_rep1_R2_fastqc.zip
```

## Recommended HPC Run

From inside the `nf-fastqc` folder:

```bash
cd /path/to/nf-fastqc

nextflow run main.nf -profile hpc \
  --samples_master /path/to/samples_master.csv \
  --project_folder /path/to/output_project \
  --fastqc_output fastqc_output
```

Resume a previous run:

```bash
nextflow run main.nf -profile hpc -resume \
  --samples_master /path/to/samples_master.csv \
  --project_folder /path/to/output_project \
  --fastqc_output fastqc_output
```

Override the HPC notification email:

```bash
nextflow run main.nf -profile hpc \
  --samples_master /path/to/samples_master.csv \
  --project_folder /path/to/output_project \
  --mail_user molendo.hpc@gmail.com
```

## Local Test Run

Use local mode only for small test data:

```bash
nextflow run main.nf -profile local \
  --fastqc_raw_data /path/to/test_fastq \
  --fastqc_pattern "*fastq.gz" \
  --project_folder ./test_output
```

## Key Parameters

| Parameter | Meaning | Default |
| --- | --- | --- |
| `samples_master` | CSV containing FASTQ paths | `null` |
| `fastqc_raw_data` | FASTQ input folder when not using CSV | `null` |
| `fastqc_pattern` | FASTQ filename pattern | `*fastq.gz` |
| `project_folder` | Base output folder | current folder |
| `fastqc_output` | FastQC output subfolder | `fastqc_output` |
| `cpus` | CPUs per FastQC task | `4` |
| `memory` | Memory per task | `8GB` |
| `time` | Runtime limit per task | `2h` |
| `mail_user` | HPC notification email | `molendo.hpc@gmail.com` |

## Existing Results Are Skipped

For each FASTQ file, the module checks whether both files already exist:

```text
sample_fastqc.html
sample_fastqc.zip
```

If both exist, that FASTQ file is skipped. If one is missing, FastQC runs again for that FASTQ file.

## Troubleshooting

If the run fails:

1. Check the main Nextflow log:

```bash
less .nextflow.log
```

2. Check the failed task error file:

```bash
less work/<hash>/.command.err
```

3. Common problems:

- FASTQ path is wrong in `samples_master`.
- `configs/slurm.config` points to a missing Singularity image.
- The HPC bind path in `extra_mounts` does not include the FASTQ or output location.
- Docker is not running for local mode.

## Project Structure

```text
main.nf
nextflow.config
configs/
  local.config
  slurm.config
```
