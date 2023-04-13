process ADD_COLUMNS {
    tag "$samplesheet"
    
    conda "conda-forge::python=3.8.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'quay.io/biocontainers/python:3.8.3' }"
    
    input:
    path samplesheet
    
    output:
    path '*.csv'       , emit: csv
    path "versions.yml", emit: versions
    
    when:
    task.ext.when == null || task.ext.when
    
    // This script is from the slideseq-tools custom package
    // https://github.com/bahnk/slideseq-tools-py
    script:
    """
    check_slideseq_samplesheet \\
        --launch-dir "$workflow.launchDir" \\
        $samplesheet \\
        samplesheet.slideseq.csv
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
        slideseq-tools: \$(pip show slideseq-tools | sed -n '/^Version/s/.*: //p')
    END_VERSIONS
    """
}
