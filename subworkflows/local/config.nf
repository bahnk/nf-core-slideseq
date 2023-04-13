//
// Check input samplesheet
//

include { ADD_COLUMNS } from '../../modules/local/samplesheet/add_columns'

workflow CONFIG {
    take:
    samplesheet // path: /path/to/samplesheet.csv

    main:
    ADD_COLUMNS ( samplesheet )
        .csv
        .splitCsv ( header:true, sep:',' )
        .map { create_fastq_channel(it) }
        .set { reads }

    emit:
    reads                               // channel: [ val(meta), [ reads ] ]
    versions = ADD_COLUMNS.out.versions // channel: [ versions.yml ]
}

// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
def create_fastq_channel(LinkedHashMap row) {

    // metadata
    def meta = [:]
    row.each{
        if ( ! ["fastq_1", "fastq_2"].contains(it.key) ) {
            meta[it.key] = it.value
        }
    }

    // nf-core uses this
    meta.id = meta.sample

    // genome
    meta.gtf = params.genomes.get(meta.genome).gtf
    meta.star = params.genomes.get(meta.genome).star

    // metadata and FASTQ files
    return [ meta, [ file(row.fastq_1), file(row.fastq_2) ] ]
}
