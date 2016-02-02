#!/usr/bin/perl
use strict;
# Script to parse BLAST results as fasta file. Required: BLAST database as fasta file, tabular BLAST output (BLAST+: '-outfmt 6', BLAST: '-m 8').
# Output will be directed to STDOUT. Sequence names in output will contain information on BLAST search (query name, length of hit, % identity, evalue).
# The complete fasta and BLAST files will be read into memory, so this script will not work on extremely large files! 
my $blastfile = $ARGV[0];
my $fastafile = $ARGV[1];
# define input files
if(!defined $ARGV[0] && !defined $ARGV[1]){
	print "This script will parse BLAST hits from a fasta file.\nUSAGE:\tperl blast2fasta_1.1.pl [BLAST output] [fasta file]\n";
	}
# Check if input files were provided, else show usage information	
open (BLAST , '<' , $blastfile) or die "\n>FILE MISSING<\n\nplease specify path to tabular BLAST output!\n\n";	
# open BLAST file or die with error message
my @querynames;
my @blastline;
my @seqnames;
my @startseq;
my @endseq;
my @evalue;
my @length;
my @identity;
my @reversenumbers;
my $linecounter=-1;
# define variables
while (my $line = <BLAST>) {
# read through BLAST output line by line
  	chomp $line;
  	$linecounter++;
  	@blastline=undef; 
  	@blastline = split /\t/, $line;
  	# split at tabs, store each of the columns in array
  	if(scalar(@blastline)!=12){
  		die "BADLY FORMATTED BLAST FILE!\nUse '-outfmt 6' option in BLAST+!\n";}
  		# check if BLAST output contains 12 columns- if not, print error message and die  		
  	else{
  	  	push(@querynames,$blastline[0]);
  		push(@seqnames,$blastline[1]);
  		push(@evalue,$blastline[10]);
  		push(@length,$blastline[3]);
  		push(@identity,$blastline[2]);
  		# store query names, subject sequence names, evalue of hits, length of hits and % identity in separate arrays
  		if($blastline[8]<=$blastline[9]){
  			push(@startseq,$blastline[8]);
  			push(@endseq,$blastline[9]);
  			if($blastline[7]<=$blastline[6]){
				push(@reversenumbers, $linecounter);
				}
  			}
  		else{
  			push(@startseq,$blastline[9]);
  			push(@endseq,$blastline[8]);
  			if($blastline[6]<=$blastline[7]){
				push(@reversenumbers, $linecounter);
				}
  			}
  		# finally, store start and end postion of hit in separate arrays
  		# if hit is on minus strand, revert start and end!		
  		}
  	}

close(BLAST);
open (FASTA , '<' , $fastafile) or die "\n>FILE MISSING<\n\nplease specify path to fasta file!\n\n";	
# open FASTA file or die with error message
my $linecount = -1;
my @names;
my @seqs;
my $sequence; 
# define variables 	
while (my $line = <FASTA>) {
  	chomp $line;
  	# chomp through fasta file line by line						
  	if ($line=~ /\>/g){						
  		$linecount++;					
		$names[$linecount]=$line;				 
		$sequence=undef;	
		# search for > with regexpr, if present, write name into array				
		}
	else{
		$seqs[$linecount] = $sequence.= uc($line);
		# other lines = sequences, write into another array	
		}
}
close(FASTA);

# Subroutine for reverse complementing a sequence
sub revcom {
    my($dna) = @_;
    # First reverse the sequence
    my $revcom = reverse $dna;
    # Next, complement the sequence, dealing with upper and lower case
    # A->T, T->A, C->G, G->C
    $revcom =~ tr/ACGTacgt/TGCAtgca/;
    return $revcom;
}

# now, use BLAST arrays and sequence arrays to write out the desired parts of the fasta file:	
my $seqnamecounter=-1;
my $namecounter;
my $substring;
my $revstring;
# define variables
foreach my $seqname(@seqnames){
# do for each of the subject sequences from the BLAST output:
	$seqnamecounter++;
		# count each loop	
		$namecounter=-1;
		# reset counter for next loop	
		foreach my $name(@names){
		# do for each sequence of original fasta file:	
			$name=~s/>//;
			# get rid of '>'		
			$namecounter++;
			# count each loop		
			if($name eq $seqname){
			if ( grep( /^$seqnamecounter$/,  @reversenumbers ) ) {
				# if one of the sequence names corresponds to the subject sequence in the BLAST output:
				$substring = substr($seqs[$namecounter], $startseq[$seqnamecounter]-1, $endseq[$seqnamecounter]-$startseq[$seqnamecounter]+1);
				$revstring = revcom($substring);
				# use a substring of the corresponding fasta sequence 
				# structure: [which sequence], [offset (=stored start position)], [length (=end position minus start position)]
				print ">".$seqname."_query:".$querynames[$seqnamecounter]."_length:".$length[$seqnamecounter]."_pid:".$identity[$seqnamecounter]."_evalue:".$evalue[$seqnamecounter],"\n$revstring\n"
				# finally, print name, information on BLAST search and sequence to STDOUT
				}
			else{# if one of the sequence names corresponds to the subject sequence in the BLAST output:
				$substring = substr($seqs[$namecounter], $startseq[$seqnamecounter]-1, $endseq[$seqnamecounter]-$startseq[$seqnamecounter]+1);
				# use a substring of the corresponding fasta sequence 
				# structure: [which sequence], [offset (=stored start position)], [length (=end position minus start position)]
				print ">".$seqname."_query:".$querynames[$seqnamecounter]."_length:".$length[$seqnamecounter]."_pid:".$identity[$seqnamecounter]."_evalue:".$evalue[$seqnamecounter],"\n$substring\n"
				# finally, print name, information on BLAST search and sequence to STDOUT
				}
			}	
		}
		
}
					
