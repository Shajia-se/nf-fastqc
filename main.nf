#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
 * nf-fastqc main script
 * - Input:  *.fastq.gz under params.fastqc_raw_data
 * - Output: FastQC HTML + ZIP reports under ${params.project_folder}/${fastqc_output}
 * - Resources and container settings are controlled via nextflow.config
 */

process fastqc {
  tag "${f}"                 // indicates which file is being processed in logs
  stageInMode 'symlink'      // symlink input files into the work directory
  stageOutMode 'move'        // move results out of the work directory after completion

  input:
    path f                   // single FASTQ file
    val fastqc_output        // output directory name (string)

  publishDir "${params.project_folder}", mode: 'copy'

  script:
  """
    mkdir -p ${fastqc_output}
    fastqc -t ${task.cpus} -o ${fastqc_output} ${f}
  """
}

workflow {

    // Define output directory name (default = "fastqc_output")
    def fastqc_output = params.fastqc_output ?: "fastqc_output"

    // Load all *.fastq.gz files from the raw data directory
    def data = Channel.fromPath("${params.fastqc_raw_data}/*fastq.gz")

    // Skip samples whose FastQC report already exists
    data = data.filter { fq ->
        def fqName   = fq.getName()
        def htmlName = fqName.replaceAll(/.fastq.gz$/, "_fastqc.html")
        ! file("${params.project_folder}/${fastqc_output}/${htmlName}").exists()
    }

    // Run FastQC
    fastqc(data, fastqc_output)
}
