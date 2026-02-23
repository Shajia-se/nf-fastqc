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
  mkdir -p tmp
  export TMPDIR=\$PWD/tmp
  export _JAVA_OPTIONS="-Djava.io.tmpdir=\$PWD/tmp"
  fastqc -t ${task.cpus} ${f}

  """
}

workflow {

  def outdir = "${params.project_folder}/${fastqc_output}"

  def data
  if (params.samples_master) {
    data = Channel
      .fromPath(params.samples_master, checkIfExists: true)
      .splitCsv(header: true)
      .filter { row ->
        def enabled = row.enabled?.toString()?.trim()?.toLowerCase()
        enabled == null || enabled == '' || enabled == 'true'
      }
      .flatMap { row ->
        def files = []
        if (row.fastq_r1?.toString()?.trim()) files << file(row.fastq_r1.toString().trim())
        if (row.fastq_r2?.toString()?.trim()) files << file(row.fastq_r2.toString().trim())
        files
      }
      .map { fq ->
        assert fq.exists() : "FASTQ not found from samples_master: ${fq}"
        fq
      }
      .unique()
      .ifEmpty { exit 1, "ERROR: No FASTQ files found from samples_master: ${params.samples_master}" }
  } else {
    // load FASTQ by configurable pattern
    def pattern = params.fastqc_pattern ?: "*fastq.gz"
    data = Channel
      .fromPath("${params.fastqc_raw_data}/${pattern}", checkIfExists: true)
      .ifEmpty { exit 1, "ERROR: No FASTQ files found for pattern: ${params.fastqc_raw_data}/${pattern}" }
  }

  // skip samples that already have HTML report
  data = data.filter { f ->
    def fqName   = f.getName()
    def htmlName = fqName.replaceFirst(/\.(fastq|fq)(\.gz)?$/, "_fastqc.html")
    ! file("${outdir}/${htmlName}").exists()
  }

  // run FastQC on all remaining files
  fastqc(data)
}
