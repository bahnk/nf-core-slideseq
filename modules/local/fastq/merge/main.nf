process MERGE {

	tag "$meta.id"

	input:
	tuple val(meta), path(reads1), path(reads2)

	output:
	tuple val(meta), path("${meta.id}.R1.fastq.gz"), path("${meta.id}.R2.fastq.gz")  ,  emit: reads
	path "versions.yml"                                                              ,  emit: versions

	script:
	def n1 = reads1.size()
	def n2 = reads2.size()

    // this should fail because the output files will be missing
    // no need to return an error value
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

		cp -v $reads1 "${meta.id}.R1.fastq.gz"
		cp -v $reads2 "${meta.id}.R2.fastq.gz"

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            bash: \$(bash --version | sed -n '1s/.*version \\([0-9\\.]\\+\\).*/\\1/p')
            cat: \$(cat --version | sed -n '1s/.* //p')
        END_VERSIONS
		"""
	}

	else
	{
		"""
		echo "Read 1 has ${n1} files"
		echo "Read 2 has ${n2} files"
		echo "We merge the files"

		cat $reads1 > "${meta.id}.R1.fastq.gz"
		cat $reads2 > "${meta.id}.R2.fastq.gz"

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            bash: \$(bash --version | sed -n '1s/.*version \\([0-9\\.]\\+\\).*/\\1/p')
            cat: \$(cat --version | sed -n '1s/.* //p')
        END_VERSIONS
		"""
	}
}
