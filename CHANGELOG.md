# aquascope dev
### feature
### fixes
### doc updates
### deprecated
### other

# aquascope v2.1 [05/16/24]
### feature
- feat: Freyja allows Amino Acid (AA) calls as output 
- feat: Freyja users can set a variant threshold above 0 to accommodate space constraints
### doc updates
- docs: updated README, CHANGELOG, user-logs

# aquascope v2.0 [05/02/24]
### feature
- feat: Added processing of Ion-torrent Bams and ONT long reads
- feat: Added Nanoplot as Quality metrics tool for ONT long reads
- feat: Samtools ampliconclip is used as primary trimming tool for ONT-long reads.
- feat: MultiQC report shows Freyja Demix results.
- feat: fasta and gff are now defaulted to assets folder. User input required to change these references 
### fixes
- fix: removed ivar trim which was erroring for ONT-long reads
- fix: Removed parameter --fai (fasta index), it now builds using samtools faidx
### doc updates
- Update README.md by @SMorrison42 in #12
- Hseabolt patch 1 by @slsevilla in #25
- Docs Overhaul, CI addition, IVAR feat add by @slsevilla in #21
- docs: updated README
- docs: update CHANGELOG format
- docs: created a VERSION log
### other
- refactor: specify primer bed file as 7th column in samplesheet - refer to ReadME file
- refactor: Qualimap Bamqc and Ivar variant calling now use "gff" file as one of the parameters, instead of bed or gff3 file formats.
- ci: added github actions for deployment

# aquascope v1.0 [8/25/23]
Initial release of nf-core/aquascope, created with the [nf-core](https://nf-co.re/) template.
