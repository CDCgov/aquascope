# nf-core/aquascope: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## dev

## v3.0.0


## v2.3.1
### `Added`
added awk to assign gff_feature to freyja - variant calls by @arunbodd in #53


## v2.3.0
### `Added`
chore: remove conflicting code by @arunbodd in #51
Add test profile for ONT data, add test data, update configs, cleanup gitignore files by @slsevilla in #49
Rebase dev from testprofiles, add new config by @arunbodd in #50
Rebasing dev to main after issues with previous merge by @slsevilla in #52

## v2.2.0

### `Added`
Merge pull request #40 from CDCgov/dev by @arunbodd in #47

### `Fixed`
Re: Reheader Bam issue addressed by @arunbodd in #40
Update images, samplesheet updates, rehead BAM by @slsevilla in #45

## v2.1.0

### `Added`
- Feature Add: Amino Acid calling, threshold features added #27 by @arunbodd @schavan023 in #31

### `Docs`
- Updated README and user-docs by @slsevilla @arunbodd in #29, #30, #33

## v2.0

### `Added`
 - feat: Added processing of Ion-torrent Bams and ONT long reads
 - feat: Added Nanoplot as Quality metrics tool for ONT long reads
 - feat: Samtools ampliconclip is used as primary trimming tool for ONT-long reads.
 - refactor: specify primer bed file as 7th column in samplesheet - refer to ReadME file
 - refactor: Qualimap Bamqc and Ivar variant calling now use "gff" file as one of the parameters, instead of bed or gff3 file formats.
 - feat: MultiQC report shows Freyja Demix results.
 - feat: fasta and gff are now defaulted to assets folder. User input required to change these references (We strongly suggest users * * not to use a different reference, as it may lead to accession ID conflicts downstream)
 - ci: added github actions for deployment

### `Fixed`
 - Hseabolt patch 1 by @slsevilla in #25
 - fix: removed ivar trim which was erroring for ONT-long reads
 - fix: Removed parameter --fai (fasta index), it now builds using samtools faidx

### `Docs`
 - Update README.md by @SMorrison42 in #12
 - Docs Overhaul, CI addition, IVAR feat add by @slsevilla in #21
 - docs: updated README
 - docs: update CHANGELOG format
 - docs: created a VERSION log

### `Deprecated`

## v1.0dev - [date]
- Initial release of nf-core/aquascope, created with the [nf-core](https://nf-co.re/) template.