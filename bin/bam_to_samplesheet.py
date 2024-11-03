#!/usr/bin/env python

import os
import argparse

def parse_args():
    parser = argparse.ArgumentParser(
        description="Generate a samplesheet from a directory of BAM files for Freyja subworkflow",
        epilog="Usage: python bam_to_samplesheet.py --directory <PATH_TO_BAM_FILES> --output <OUTPUT_FILE>"
    )
    parser.add_argument("--directory", help="Directory containing BAM files.", required=True)
    parser.add_argument("--output", help="Output file for the samplesheet.", required=True)
    return parser.parse_args()

def extract_sample_name(bam_filename):
    """
    Extracts the sample name from the BAM filename assuming the sample name
    is the first component before the first ".".
    """
    return bam_filename.split(".")[0]

def generate_samplesheet(directory, output_file):
    bam_files = [f for f in os.listdir(directory) if f.endswith(".bam")]
    with open(output_file, "w") as fout:
        fout.write("sample,bam_file\n")
        for bam_file in bam_files:
            sample_name = extract_sample_name(bam_file)
            bam_path = os.path.abspath(os.path.join(directory, bam_file))
            fout.write(f"{sample_name},{bam_path}\n")

def main():
    args = parse_args()
    generate_samplesheet(args.directory, args.output)

if __name__ == "__main__":
    main()
