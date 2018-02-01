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


#### gc_cov.pl
        This script will draw simple GC coverage plots from SPAdes assembly files. It uses the information on kmer coverage and contig lengths given in the SPAdes assembly files.
        Please note that the coverage therefore does not correspond to actual nucleotide coverage, but to kmer coverage as estimated by SPAdes with the largest kmer used in assembly!
        Requires Perl module 'Statistics::R' and R packages 'ggplot2' and 'viridis'.

        USAGE	perl gc_cov.pl [OPTIONS] assembly.fasta
        OPTIONS
        --taxonomy [FILE]	path to taxonomy file that will be used to annotate the plot (optional)
        --ntaxa [N]		the number of most frequently occuring taxa to annotate (optional, only in conjunction with --taxonomy)

        Format for taxonomy file:
        contigname1	taxonname
        contigname2	taxonname
        ...



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

This script downloads fastq files from the European Nucleotide Archive (ENA) database.	

* Requires EITHER wget version 1.16 & up (https://ftp.gnu.org/gnu/wget/) OR ascp (https://downloads.asperasoft.com/en/downloads/50)

* To access the ENA database with ascp, you will need a private key file that is included with the ascp package. Depending on your system, you may need to tell the script where this key file can be found (default is "$HOME/.aspera/connect/etc/asperaweb_id_dsa.openssh") 

* If possible, using ascp is recommended, as download speeds are much higher than with wget (often up to 300-500 MB/s) 
	
* Input file should contain only a single SRA accession number per line and no white spaces (accession numbers are identical to NCBI's SRA accession numbers)
	
* This script will access European servers, and thus is probably most efficient when used in Europe.

* Please refer to https://www.ebi.ac.uk/ena/browse/read-download for details on how fastq files from SRA studies are stored at ENA and can be accessed

* The script will sort the file with accession numbers, if an unsorted one was provided.

        USAGE	perl sra_dowload.pl [OPTIONS] accessions.txt
        OPTIONS
         --ascp	Use ascp (Aspera secure copy) instead of wget to fetch the files
         --id    	Path to Aspera private key file (defaults to ~/.aspera/connect/etc/asperaweb_id_dsa.openssh, only in conjunction with --ascp)



