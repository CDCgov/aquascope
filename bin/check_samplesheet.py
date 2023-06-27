#!/usr/bin/env python

import os
import sys
import errno
import argparse


def parse_args(args=None):
    Description = "Reformat nf-core/aquascope samplesheet file and check its contents."
    Epilog = "Example usage: python check_samplesheet.py <FILE_IN> <FILE_OUT>"

    parser = argparse.ArgumentParser(description=Description, epilog=Epilog)
    parser.add_argument("FILE_IN", help="Input samplesheet file.")
    parser.add_argument("FILE_OUT", help="Output file.")
    return parser.parse_args(args)


def make_dir(path):
    if len(path) > 0:
        try:
            os.makedirs(path)
        except OSError as exception:
            if exception.errno != errno.EEXIST:
                raise exception


def print_error(error, context="Line", context_str=""):
    error_str = "ERROR: Please check samplesheet -> {}".format(error)
    if context != "" and context_str != "":
        error_str = "ERROR: Please check samplesheet -> {}\n{}: '{}'".format(
            error, context.strip(), context_str.strip()
        )
    print(error_str)
    sys.exit(1)


# TODO nf-core: Update the check_samplesheet function
def check_samplesheet(args):
    file_in = args.FILE_IN
    file_out = args.FILE_OUT

    """
    This function checks that the samplesheet follows the following structure:

    sample,sequencing_platform,fastq_1,fastq_2
    SAMPLE_PE,sequencing_platform,SAMPLE_PE_RUN1_1.fastq.gz,SAMPLE_PE_RUN1_2.fastq.gz
    SAMPLE_PE,sequencing_platform,SAMPLE_PE_RUN2_1.fastq.gz,SAMPLE_PE_RUN2_2.fastq.gz
    SAMPLE_SE,sequencing_platform,SAMPLE_SE_RUN1_1.fastq.gz,

    For an example see:
    https://raw.githubusercontent.com/nf-core/test-datasets/viralrecon/samplesheet/samplesheet_test_illumina_amplicon.csv
    """

    sample_mapping_dict = {}
    with open(file_in, "r") as fin:

        ## Check header
        MIN_COLS = 2
        HEADER = ["sample", "sequencing_platform", "fastq_1", "fastq_2"]
        header = [x.strip('"') for x in fin.readline().strip().split(",")]
        if header[: len(HEADER)] != HEADER:
            print(
                "ERROR: Please check samplesheet header -> {} != {}".format(
                    ",".join(header), ",".join(HEADER)
                )
            )
            sys.exit(1)

        ## Check sample entries
        for line in fin:
            lspl = [x.strip().strip('"') for x in line.strip().split(",")]

            # Check valid number of columns per row
            if len(lspl) < len(HEADER):
                print_error(
                    "Invalid number of columns (minimum = {})!".format(len(HEADER)), "Line", line
                )
            num_cols = len([x for x in lspl if x])
            if num_cols < MIN_COLS:
                print_error(
                    "Invalid number of populated columns (minimum = {})!".format(MIN_COLS),
                    "Line",
                    line,
                )

            ## Check sample name entries
            sample, sequencing_platform, fastq_1, fastq_2 = lspl[: len(HEADER)]
            sample = sample.replace(" ", "_")
            if not sample:
                print_error("Sample entry has not been specified!", "Line", line)

            ## Check FastQ file extension
            for fastq in [fastq_1, fastq_2]:
                if fastq:
                    if fastq.find(" ") != -1:
                        print_error("FastQ file contains spaces!", "Line", line)
                    if not fastq.endswith(".fastq.gz") and not fastq.endswith(".fq.gz"):
                        print_error(
                            "FastQ file does not have extension '.fastq.gz' or '.fq.gz'!",
                            "Line",
                            line,
                        )

            ## Auto-detect paired-end/single-end
            sample_info = []  ## [sequencing_platform, single_end, fastq_1, fastq_2]
            if sample and sequencing_platform and fastq_1:
                if sequencing_platform.lower() == "illumina":
                    if fastq_2:  ## Paired-end short reads for Illumina
                        sample_info = [sequencing_platform, "0", fastq_1, fastq_2]
                    else:  ## Single-end short reads for Illumina
                        sample_info = [sequencing_platform, "1", fastq_1, ""]
                elif sequencing_platform.lower() in ["nanopore", "pacbio"]:  ## Single-end long reads for Nanopore and PacBio
                    sample_info = [sequencing_platform, "1", fastq_1, ""]
            else:
                print_error("Invalid combination of columns provided!", "Line", line)

            ## Create sample mapping dictionary = { sample: [ sequencing_platform, single_end, fastq_1, fastq_2 ] }
            if sample not in sample_mapping_dict:
                sample_mapping_dict[sample] = [sample_info]
            else:
                if sample_info in sample_mapping_dict[sample]:
                    print_error("Samplesheet contains duplicate rows!", "Line", line)
                else:
                    sample_mapping_dict[sample].append(sample_info)

    ## Write validated samplesheet with appropriate columns
    if len(sample_mapping_dict) > 0:
        out_dir = os.path.dirname(file_out)
        make_dir(out_dir)
        with open(file_out, "w") as fout:
            fout.write(",".join(["sample", "sequencing_platform", "single_end", "fastq_1", "fastq_2"]) + "\n")
            for sample in sorted(sample_mapping_dict.keys()):
                for sample_info in sample_mapping_dict[sample]:
                    fout.write(",".join([sample] + sample_info) + "\n")
    else:
        print_error("No entries to process!", "Samplesheet: {}".format(file_in))


def main(args=None):
    check_samplesheet(args)


if __name__ == "__main__":
    main(parse_args())
