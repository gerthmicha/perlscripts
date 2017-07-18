# perlscripts

A collection & backup of my perl scripts. Short description for all of them is given below.


#### assembly_stats.pl 

This script will calculate and display basic assembly statistics.

USAGE    perl assembly_stats.pl [OPTIONS] assembly.fasta [assembly2.fasta]

OPTIONS

   --min_contig_length [N]      minimal size of contigs to be included in statistics (optional)

   --pdf                        generate a PDF file containing three descriptive plots (requires R installation in system path)

   --compare                    calculate assembly statistics for two assemblies in parallel


#### blast2fasta.pl

This script will parse BLAST hits from a fasta file.

USAGE:	perl blast2fasta_1.1.pl [BLAST output] [fasta file]


#### cogparser.pl

This script will parse COG information after blasting query proteins against COG proteins.

USAGE:	perl cogparser.pl [BLAST output] [list of orthology domains] [list of COG annotations]

NOTE:	COG files can be downloaded from ftp://ftp.ncbi.nih.gov/pub/COG


#### extract_long.pl

This script extracts the longest sequence from each fasta-file in the current directory.


#### extract_seqs_by_id.pl                                              
This script will extract those sequences from a fasta file that match (or do not match) provided IDs

USAGE:  perl extract_seqs_by_id.pl [--exclude] input.fasta IDs.txt (one ID per line)
        --exclude creates fasta file containing all sequences that DO NOT match provided IDs
        (default: create fasta file containing all sequences that DO match provided IDs)


#### extract_unique_seqs.pl

This script will extract unique sequences from a fasta file. The longest sequence of each unique ID will be printed to a fasta file.
When identical sequences are present, a reduced fasta file containing only unique IDs AND sequences will be printed to another file.

USAGE: perl extract_unique_seqs.pl input.fasta


#### fastq_combine.pl                                                     
this script creates a single file out of paired end read files

USAGE:  perl fastq_combine.pl [--fasta --no-check] readfile_1.fastq readfile_2.fastq


#### filter_empty.pl

This script filters empty sequences from a fasta file.

USAGE: perl filter_empty.pl input.fasta


#### filter_length.pl                                                    
This script will filter fasta files by length.

USAGE:   perl filter_length.pl [minlength] [maxlength] input.fasta


#### GC.pl

This script calculates GC values from each sequence of a given fasta file.

USAGE: perl GC.pl input.fasta


#### ncbi2fasta.pl

This script will fetch nucleotide sequences from NCBI GenBank based on their accession numbers.

USAGE: perl ncbi2fasta.pl accessions.txt


#### RY_coder.pl                                                           
This script turns a regular nucleotid alignment into an RY-coded alignment.

USAGE: perl RY_coder.pl input.fasta


##### singularize_seqs.pl                                                 
This script creates single sequence files from any multi-sequence fasta file.

USAGE: perl singularize_seqs.pl input.fasta


#### split_fasta.pl

This sript will extract paired-end reads from a fasta file and create single files for forward, reverse and unpaired reads.

USAGE:  perl split_fasta.pl input_fasta


#### split_partitions.pl

This script will create single fasta files out of a larger alignment based on a partitioning scheme.

USAGE:          perl split_partitions.pl [fasta file] [partition file]

Example of a partition file:

partition1=1-100 201-300
partition2=101-200
...


#### sra_download.pl

This script will download fastq files from the European Nucleotide Archive database. Requires input file with a single SRA accession number per line (accession numbers areidentical to NCBI's SRA accession numbers). Please note that this will access European servers, and thus probably be most efficient when used in Europe. Please also note that this script will sort the file with accession numbers, if an unsorted one was provided. The script will print some info during and after the downloads and will also create a log file for the wget processes. However, I recommend to manually check if all files were completely downloaded after runnning the script. 

USAGE:  perl sra_dowload.pl accessions.txt


