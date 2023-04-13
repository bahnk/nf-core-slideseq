//
// Preprocess Slide-seq reads before alignment
//

include { MERGE } from '../../modules/local/fastq/merge'

workflow PREPROCESS {
    take:
    reads // channel: [ val(map:meta), [ path(fastq_1), path(fastq_2) ] ]

    main:
    reads
        .map { [ it[0]["sample"] , it ] }
        .groupTuple()
        .map { [
            it[1][0][0],

            // this way the order should be preserved
            // and the two lists should be paired with
            // read 1 matching its proper read 2
            it[1].collect{ sample -> sample[1][0] },
            it[1].collect{ sample -> sample[1][1] }
        ] }
        .set { samples }

    MERGE ( samples )

    emit:
    reads = MERGE.out.reads                 // channel: [ val(map:meta), [ path(fastq_1), path(fastq_2) ] ]
    versions = MERGE.out.versions   // channel: [ versions.yml ]
}

