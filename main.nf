#!/usr/bin/env nextflow
nextflow.enable.dsl=2

def fastqc_output = params.fastqc_output ?: "fastqc_output"

process fastqc {
  tag "${f}"                 
  stageInMode 'symlink'      
  stageOutMode 'move'        

  input:
    path f                

  publishDir "${params.project_folder}/${fastqc_output}", mode: 'copy'

  output:
    path "*_fastqc.html"
    path "*_fastqc.zip"

  script:
  """
  fastqc -t ${task.cpus} ${f}

  """
}

workflow {

  def outdir = "${params.project_folder}/${fastqc_output}"

  // load FASTQ by configurable pattern
  def pattern = params.fastqc_pattern ?: "*fastq.gz"
  def data = Channel
    .fromPath("${params.fastqc_raw_data}/${pattern}", checkIfExists: true)
    .ifEmpty { exit 1, "ERROR: No FASTQ files found for pattern: ${params.fastqc_raw_data}/${pattern}" }

  // skip samples that already have HTML report
  data = data.filter { f ->
    def fqName   = f.getName()
    def htmlName = fqName.replaceFirst(/\.fastq\.gz$/, "_fastqc.html")
    ! file("${outdir}/${htmlName}").exists()
  }

  // run FastQC on all remaining files
  fastqc(data)
}
