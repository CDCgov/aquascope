#!/usr/bin/env python3.9

import os
import sys
import argparse
import http.client
import urllib.parse

VALID_PLATFORMS = {"illumina", "nanopore", "iontorrent"}
EXPECTED_HEADERS = ["sample", "platform", "fastq_1", "fastq_2", "lr", "bam_file", "bedfile"]
MIN_COLS_REQUIRED = 3

## Args parser for the script with i/o options
def parse_args(args=None):
    parser = argparse.ArgumentParser(
        description="Reformat nf-core/aquascope samplesheet file and check its contents.",
        epilog="Example usage: python check_samplesheet.py <FILE_IN> <FILE_OUT>",
    )
    parser.add_argument("FILE_IN", help="Input samplesheet file.")
    parser.add_argument("FILE_OUT", help="Output samplesheet file.")
    return parser.parse_args(args)

## Define case_sensitive realpaths for all input files
def find_case_sensitive_path(path):
    if os.path.exists(path):
        return os.path.realpath(path)

    dirname, basename = os.path.split(path)
    if not os.path.exists(dirname):
        return None

    files = os.listdir(dirname)
    for file in files:
        if file.lower() == basename.lower():
            return os.path.realpath(os.path.join(dirname, file))

    return None

## Validate Fastq files with either .fastq.gz or fq.gz extension
def validate_fastq(fastq_file, line):
    fastq_file_path = find_case_sensitive_path(fastq_file)
    if not fastq_file_path:
        print(f"FastQ file '{fastq_file}' does not exist! Line: {line}")
        return fastq_file
    if " " in fastq_file:
        print(f"FastQ file '{fastq_file}' contains spaces! Line: {line}")
    if not fastq_file.lower().endswith((".fastq.gz", ".fq.gz")):
        print(f"FastQ file '{fastq_file}' does not have extension '.fastq.gz' or '.fq.gz'! Line: {line}")
    return fastq_file_path

## Validate BAM with .bam extensions
def validate_bam(bam_file, line):
    bam_file_path = find_case_sensitive_path(bam_file)
    if not bam_file_path:
        print(f"BAM file '{bam_file}' does not exist! Line: {line}")
        return bam_file
    if not bam_file.lower().endswith(".bam"):
        print(f"BAM file '{bam_file}' does not have extension '.bam'! Line: {line}")
    return bam_file_path

## Download and validate bedfile - proceed if the bedfile has at least 6 columns
def validate_bedfile(bedfile, line, platform):
    if bedfile:
        if bedfile.startswith(("http://", "https://")):
            parsed_url = urllib.parse.urlparse(bedfile)
            conn = http.client.HTTPConnection(parsed_url.netloc) if parsed_url.scheme == "http" else http.client.HTTPSConnection(parsed_url.netloc)
            conn.request("GET", parsed_url.path)
            response = conn.getresponse()
            if response.status == 200:
                print(f"Downloading BED file from '{bedfile}'")
                lines = response.read().decode('utf-8').splitlines()
                print("First 4 rows of the BED file:")
                for i, bed_line in enumerate(lines[:4]):
                    print(f"Row {i+1}: {bed_line}")
                for i, bed_line in enumerate(lines):
                    cols = bed_line.strip().split("\t")
                    if len(cols) < 6:
                        print(f"Bed file '{bedfile}' must have at least 6 columns! (Line {i+1}) Line: {line}")
            else:
                print(f"Failed to download bed file '{bedfile}': {response.status} Line: {line}")
        else:
            if not os.path.isfile(bedfile):
                print(f"Bed file '{bedfile}' does not exist! Line: {line}")
            else:
                with open(bedfile, "r") as f:
                    print(f"Reading BED file from '{bedfile}'")
                    lines = f.readlines()
                    print("First 4 rows of the BED file:")
                    for i, bed_line in enumerate(lines[:4]):
                        print(f"Row {i+1}: {bed_line.strip()}")
                    for i, bed_line in enumerate(lines):
                        cols = bed_line.strip().split("\t")
                        if len(cols) < 6:
                            print(f"Bed file '{bedfile}' must have at least 6 columns! (Line {i+1}) Line: {line}")
    elif platform != "iontorrent":
        print(f"Bedfile is required for platforms other than IonTorrent if not provided. Line: {line}")

## Extract sample name as meta id or sample column in the samplesheet from basename of file
def extract_sample_name(file_path):
    basename = os.path.basename(file_path)
    return basename.split('.')[0]


## Define and check for valid platforms and use above functions to validate various conditions
def check_samplesheet(args):
    file_in = args.FILE_IN
    file_out = args.FILE_OUT

    with open(file_in, "r") as fin:
        lines = fin.readlines()

    header = [x.strip('"') for x in lines[0].strip().split(",")]
    if header[: len(EXPECTED_HEADERS)] != EXPECTED_HEADERS:
        print(f"Invalid header! Expected {EXPECTED_HEADERS} but got {header}. Line: {','.join(header)}")

    updated_lines = [lines[0]]  # Keep the header

    for i, line in enumerate(lines[1:], start=2):
        cols = [x.strip().strip('"') for x in line.strip().split(",")]
        if len(cols) < MIN_COLS_REQUIRED:
            print(f"Invalid number of columns (minimum = {MIN_COLS_REQUIRED})! Line: {line}")
            continue

        sample, platform = cols[0], cols[1].lower()
        fastq_1, fastq_2, lr, bam_file = (cols[2:6] + [None]*4)[:4]
        bedfile = cols[6] if len(cols) > 6 else None  # Only if bedfile is specified

        if platform not in VALID_PLATFORMS:
            print(f"Invalid platform '{platform}'! Line: {line}")
            continue
        if platform == "illumina":
            if fastq_1:
                fastq_1 = validate_fastq(fastq_1, line)
                sample = extract_sample_name(fastq_1)
                if fastq_2:
                    fastq_2 = validate_fastq(fastq_2, line)
        elif platform == "nanopore" and lr:
            lr = validate_fastq(lr, line)
            sample = extract_sample_name(lr)
        elif platform == "iontorrent" and bam_file:
            bam_file = validate_bam(bam_file, line)
            sample = extract_sample_name(bam_file)

        validate_bedfile(bedfile, line, platform)

        # Update the line with the corrected paths and sample name
        cols[0], cols[1], cols[2], cols[3], cols[4], cols[5] = sample, platform, fastq_1 or '', fastq_2 or '', lr or '', bam_file or ''
        updated_lines.append(",".join(cols) + "\n")

    # Write the updated lines back to the same file and also to the output file
    with open(file_in, "w") as fout_in, open(file_out, "w") as fout_out:
        fout_in.writelines(updated_lines)
        fout_out.writelines(updated_lines)

def main(args=None):
    check_samplesheet(parse_args(args))

if __name__ == "__main__":
    main()
