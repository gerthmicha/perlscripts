#!/usr/bin/perl
use strict;

my $fasta = $ARGV[0];

open(FASTA, '<', $fasta) or die"\nThis script turns a regular nucleotid alignment into an RY-coded alignment.\nPlease provide path to a fasta file!\n\n";
my $prefix = $fasta;
$prefix =~ s/\.fa.//;

my $linecount = -1;
my @names;
my @seqs;
my $sequence;


open(OUTFILE, '>>', $prefix."_RY.fas");

while (my $line = <FASTA>) {
  	chomp $line;						# chomp through input file line by line
  	if ($line=~ /\>/g){					# search for > with regexpr, if present, write name into @seqs
  		$linecount++;					# number of sequence is counted
		$names[$linecount]=$line;			# use sequence number as index of arrays 
		$sequence=undef;				# important: reset $sequence for each new sequence!		
		print OUTFILE $line,"\n";		
}		
	else{
		$seqs[$linecount] = $sequence.= uc($line);
		$seqs[$linecount] =~ tr/aAgGcCtT/RRRRYYYY/;		
		print OUTFILE $seqs[$linecount],"\n";
		}
}
close(FASTA);
close(OUTFILE);
