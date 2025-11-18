#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
 * nf-fastqc main script
 * - Input:  *.fastq.gz under params.fastqc_raw_data
 * - Output: FastQC HTML + ZIP reports under ${params.project_folder}/${fastqc_output}
 */

process fastqc {
  tag "${f}"                 // shows which file is being processed in the logs
  stageInMode 'symlink'      // symlink input files into the work directory
  stageOutMode 'move'        // move results out of the work directory after completion

  input:
    path f                   // single FASTQ file
    val fastqc_output        // output folder name (used only for publishDir)

  // Publish all FastQC reports into:
  //   ${params.project_folder}/${fastqc_output}
  publishDir { "${params.project_folder}/${fastqc_output}" }, mode: 'copy'

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

  // Define output subfolder name (default = "fastqc_output")
  def fastqc_output = params.fastqc_output ?: "fastqc_output"

  // Load all *.fastq.gz files from the raw data directory
  def data = Channel.fromPath("${params.fastqc_raw_data}/*fastq.gz")

  // Skip samples whose FastQC report already exists in the final output directory
  data = data.filter { fq ->
    def fqName   = fq.getName()
    def htmlName = fqName.replaceAll(/.fastq.gz$/, "_fastqc.html")
    ! file("${params.project_folder}/${fastqc_output}/${htmlName}").exists()
  }

  // Run FastQC
  fastqc(data, fastqc_output)
}
