#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
 * nf-fastqc main script
 * - Input:  *.fastq.gz under params.fastqc_raw_data
 * - Output: FastQC HTML + ZIP reports under ${params.project_folder}/${OUTDIR_NAME}
 */

// Global output folder name (visible to both process and workflow)
def OUTDIR_NAME = params.fastqc_output ?: 'fastqc_output'

process fastqc {
  tag "${f}"                 // shows which file is being processed in the logs
  stageInMode 'symlink'      // symlink input files into the work directory
  stageOutMode 'move'        // move results out of the work directory after completion

  input:
    path f                   // single FASTQ file

  // Publish all FastQC reports into:
  //   ${params.project_folder}/${OUTDIR_NAME}
  publishDir { "${params.project_folder}/${OUTDIR_NAME}" }, mode: 'copy'

  // Tell Nextflow which files are the real outputs
  output:
    path "*_fastqc.html"
    path "*_fastqc.zip"

  script:
  """
  # Run FastQC in the current work directory
  fastqc -t ${task.cpus} ${f}
  """
}

workflow {

  // Absolute final output directory
  def outdir = "${params.project_folder}/${OUTDIR_NAME}"

  // Load all *.fastq.gz files from the raw data directory
  def data = Channel.fromPath("${params.fastqc_raw_data}/*fastq.gz")

  // Skip samples whose FastQC report already exists in the final output directory
  data = data.filter { fq ->
    def fqName   = fq.getName()
    def htmlName = fqName.replaceAll(/.fastq.gz$/, "_fastqc.html")
    ! file("${outdir}/${htmlName}").exists()
  }

  // Run FastQC
  fastqc(data)
}
