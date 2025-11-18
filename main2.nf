#!/usr/bin/env nextflow
nextflow.enable.dsl=2


process fastqc {
  tag "${f}"                 // shows which file is being processed in the logs
  stageInMode 'symlink'      // symlink input files into the work directory
  stageOutMode 'move'        // (not really used here since we write outside workdir)

  input:
    path f                   // single FASTQ file
    val fastqc_output        // just the folder name, e.g. "fastqc_output"

  script:
  """
  mkdir -p "${params.project_folder}/${fastqc_output}"
  fastqc -t ${task.cpus} -o "${params.project_folder}/${fastqc_output}" ${f}
  """
}

workflow {

  // decide output folder name
  def fastqc_output = params.fastqc_output ?: "fastqc_output"

  // load all *.fastq.gz
  def data = Channel.fromPath("${params.fastqc_raw_data}/*fastq.gz")

  // skip samples that already have HTML report
  data = data.filter { f ->
    def fqName   = f.getName()
    def htmlName = fqName.replaceAll(/.fastq.gz$/, "_fastqc.html")
    ! file("${params.project_folder}/${fastqc_output}/${htmlName}").exists()
  }

  // run FastQC
  fastqc(data, fastqc_output)
}
