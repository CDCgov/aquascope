#!/bin/bash

bam=$1
gff=$2

echo "BAM file must be sorted, sorting now"
# Sort the unsorted BAM file
samtools sort -o "${bam}_sorted.bam" -T "${bam}_temp" "$bam"

# Extract SNID from GFF
SNID=$(awk 'NR>5 {print $1; exit}' "$gff")

# Reheader the BAM file
samtools view -H "$bam" | awk -v OFS='\t' -v SNID="$SNID" '{ if ($1 == "@SQ" && $2 == "SN:2019-nCoV") $2 = "SN:"SNID; print }' | samtools reheader -P - "$bam" > "${bam%_sorted.bam}_reheadered.bam"


# Clean up temporary files
if [ -f "${bam}_sorted.bam" ]; then
    rm "${bam}_sorted.bam"
fi

echo "Processing complete"
