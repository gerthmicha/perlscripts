# perlscripts

A collection of my perl scripts


###### assembly_stats.pl 

This script will calculate and display basic assembly statistics.

USAGE    perl assembly_stats.pl [OPTIONS] assembly.fasta [assembly2.fasta]
OPTIONS
   --min_contig_length [N]      minimal size of contigs to be included in statistics (optional)
   --pdf                        generate a PDF file containing three descriptive plots (requires R installation in system path)
   --compare                    calculate assembly statistics for two assemblies in parallel



