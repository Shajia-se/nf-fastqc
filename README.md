# nf-fastqc

`nf-fastqc` is a Nextflow DSL2 module for running FastQC on raw FASTQ files.

## What This Module Does

1. Reads FASTQ files from `params.fastqc_raw_data` using `params.fastqc_pattern`.
2. Skips samples with existing `${sample}_fastqc.html` in output.
3. Runs `fastqc` on remaining samples.
4. Publishes outputs to `${params.project_folder}/${params.fastqc_output}`.

## Input

- Directory: `params.fastqc_raw_data`
- File pattern: `params.fastqc_pattern` (default: `*fastq.gz`)
- Expected file type: gzipped FASTQ (`.fastq.gz`)
- Optional: `params.samples_master` (CSV). If provided, FASTQ files are read from columns `fastq_r1` / `fastq_r2` (rows with `enabled=false` are skipped).

## Output

Under `${project_folder}/${fastqc_output}` (default: `./fastqc_output/`):
- `*_fastqc.html`
- `*_fastqc.zip`

## Key Parameters

Defined in `nextflow.config`:
- `project_folder`: output base folder (default: `$PWD`)
- `fastqc_raw_data`: input FASTQ folder
- `fastqc_pattern`: input matching pattern
- `fastqc_output`: output folder name
- `cpus`, `memory`, `time`: process resources

## Run

```bash
nextflow run main.nf -profile local
```

```bash
nextflow run main.nf -profile hpc
```

```bash
nextflow run main.nf -profile hpc \
  --fastqc_raw_data /your/fastq/path \
  --fastqc_pattern "*fastq.gz" \
  --fastqc_output fastqc_output
```

Use samples master table:
```bash
nextflow run main.nf -profile hpc \
  --samples_master /path/to/samples_master.csv \
  --fastqc_output fastqc_output
```

Resume previous run:
```bash
nextflow run main.nf -profile hpc -resume
```

## Notes For HPC

- The module sets `TMPDIR` and Java tmpdir inside task work directory to avoid `/tmp` space issues.
- If a run fails, check `.nextflow.log` and `work/<hash>/.command.err`.

## Project Structure

```text
main.nf
nextflow.config
configs/
  local.config
  slurm.config
```
