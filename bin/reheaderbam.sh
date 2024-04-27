#!/bin/bash

bam=$1

# Check if BAM file is sorted
bamheader=$(samtools view -H $bam)

if grep -q "SO:coordinate" <<< ${bamheader}; then
    echo "BAM file is already sorted"
    # Reheader the sorted BAM file
    samtools view -H "$bam" | awk -v OFS='\t' '{ if ($1 == "@SQ" && $2 == "SN:2019-nCoV") $2 = "SN:MN908947.3"; print }' | samtools reheader -P - $bam > "${bam}_reheadered.bam"
else
    echo "BAM file is not sorted, sorting now"
    # Sort the unsorted BAM file
    samtools sort -o "${bam}_sorted.bam" -T "${bam}_temp" "$bam"
    # Reheader the sorted BAM file
    samtools view -H "${bam}_sorted.bam" | awk -v OFS='\t' '{ if ($1 == "@SQ" && $2 == "SN:2019-nCoV") $2 = "SN:MN908947.3"; print }' | samtools reheader -P - $bam > "${bam}_reheadered.bam"
    rm "${bam}_sorted.bam"
fi

echo "Processing complete"
