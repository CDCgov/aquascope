## Prepare the Samplesheet
3. Prepare the `assets/samplesheet.csv`
	A. Use the `assets/test_highcoverage_samplesheet.csv`
	B. Create additional sample sheets using the `fastq_dir_to_samplesheet.py` script
		Usage: fastq_dir_to_samplesheet.py \
			</absolute/path/to/fastq/dir> \
   			-st <forward/reverse/unstranded> \
   			samplesheetName.csv 
   		i. FASTQ files must be paired end, following `_R1`, `_R2` naming convention.
   		ii. Strandedness must be known or "unstranded". NOTE: DNASeq is by default `unstranded`, while RNASeq is usually `stranded`

## Prepare the config files

4. Prepare the configuration files
	A. TODO ARUN: what other configs need to be update
	B. `test.config` is prepared with default parameters, update as needed
