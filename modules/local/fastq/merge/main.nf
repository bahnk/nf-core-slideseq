process MERGE {

	tag "$meta.id"

	input:
	tuple val(meta), path(fastq1), path(fastq2)

	output:
	tuple val(meta), path("${meta.id}_R1.fastq.gz"), path("${meta.id}_R2.fastq.gz")  ,  emit: fastqs
	path "versions.yml"                                                              ,  emit: versions

	script:
	def n1 = meta.n_fastq_read1
	def n2 = meta.n_fastq_read2
	if ( n1 != n2 )
	{
		"""
		echo "Error: not the same number of FASTQ files for Read 1 and Read 2"
		echo "Read 1 has ${n1} files"
		echo "Read 2 has ${n2} files"
		"""
	}

	else if ( n1 == 1 )
	{
		"""
		echo "Read 1 has ${n1} file"
		echo "Read 2 has ${n2} file"
		echo "We copy the files"
		cp -v $fastq1 "${meta.id}_R1.fastq.gz"
		cp -v $fastq2 "${meta.id}_R2.fastq.gz"
		"""
	}

	else
	{
		"""
		echo "Read 1 has ${n1} files"
		echo "Read 2 has ${n2} files"
		echo "We merge the files"
		cat $fastq1 > "${meta.id}_R1.fastq.gz"
		cat $fastq2 > "${meta.id}_R2.fastq.gz"
		"""
	}
}
