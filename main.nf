#!/usr/bin/env nextflow
nextflow.enable.dsl=2


// one global output folder name so both process & workflow can see it
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

  // final output directory (used only for the skip logic)
  def outdir = "${params.project_folder}/${fastqc_output}"

  // load all *.fastq.gz
  def data = Channel.fromPath("${params.fastqc_raw_data}/*fastq.gz")

  // skip samples that already have HTML report in the FINAL output dir
  data = data.filter { f ->
    def fqName   = f.getName()
    def htmlName = fqName.replaceAll(/.fastq.gz$/, "_fastqc.html")
    ! file("${outdir}/${htmlName}").exists()
  }

  // run FastQC on all remaining files
  fastqc(data)
}
