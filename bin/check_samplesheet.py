#!/usr/bin/env python

import os
import sys
import argparse
import http.client
import urllib.parse

VALID_PLATFORMS = {"illumina", "nanopore", "iontorrent"}
EXPECTED_HEADERS = ["sample", "platform", "fastq_1", "fastq_2", "lr", "bam_file", "bedfile"]
MIN_COLS_REQUIRED = 3

def parse_args(args=None):
    parser = argparse.ArgumentParser(
        description="Reformat nf-core/aquascope samplesheet file and check its contents.",
        epilog="Example usage: python check_samplesheet.py <FILE_IN> <FILE_OUT>",
    )
    parser.add_argument("FILE_IN", help="Input samplesheet file.")
    parser.add_argument("FILE_OUT", help="Output file.")
    return parser.parse_args(args)

def validate_fastq(fastq_file, line):
    if " " in fastq_file:
        print(f"FastQ file '{fastq_file}' contains spaces! Line: {line}")
    if not fastq_file.endswith((".fastq.gz", ".fq.gz")):
        print(f"FastQ file '{fastq_file}' does not have extension '.fastq.gz' or '.fq.gz'! Line: {line}")

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

def check_samplesheet(args):
    file_in = args.FILE_IN
    file_out = args.FILE_OUT

    with open(file_in, "r") as fin, open(file_out, "w") as fout:
        header = [x.strip('"') for x in fin.readline().strip().split(",")]
        if header[: len(EXPECTED_HEADERS)] != EXPECTED_HEADERS:
            print(f"Invalid header! Expected {EXPECTED_HEADERS} but got {header}. Line: {','.join(header)}")

        fout.write(",".join(header) + "\n")

        for i, line in enumerate(fin, start=2):
            cols = [x.strip().strip('"') for x in line.strip().split(",")]
            if len(cols) < MIN_COLS_REQUIRED:
                print(f"Invalid number of columns (minimum = {MIN_COLS_REQUIRED})! Line: {line}")
                continue

            sample, platform = cols[0], cols[1].lower()
            fastq_1, fastq_2, lr, bam_file = (cols[2:6] + [None]*4)[:4]
            bedfile = cols[6] if len(cols) > 6 else None  # Only if bedfile is specified

            if platform.lower() not in VALID_PLATFORMS:
                print(f"Invalid platform '{platform}'! Line: {line}")
                continue
            if platform == "illumina":
                if fastq_1:
                    validate_fastq(fastq_1, line)
                    if fastq_2:
                        validate_fastq(fastq_2, line)
            elif platform == "nanopore" and lr and not lr.endswith((".fastq.gz", ".fq.gz")):
                print(f"Nanopore requires FastQ file in 'lr' column! Line: {line}")
            elif platform == "iontorrent" and bam_file and not bam_file.endswith(".bam"):
                print(f"IonTorrent requires BAM file! Line: {line}")

            validate_bedfile(bedfile, line, platform)
            # Write to the output file
            output_line = ",".join([sample, platform, fastq_1 or '', fastq_2 or '', lr or '', bam_file or '', bedfile or ''])
            fout.write(output_line + "\n")

def main(args=None):
    check_samplesheet(parse_args(args))

if __name__ == "__main__":
    main()
