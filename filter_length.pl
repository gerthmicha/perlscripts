#!/usr/bin/perl
use strict; 								
my $minlength = $ARGV[0];
my $maxlength = $ARGV[1];
my $inputfasta = $ARGV[2];

open (FASTA , '<' , $inputfasta) or die "\nThis script will filter fasta files by length. \nUSAGE:\t perl filter_length.pl [minlength] [maxlength] input.fasta\n\n";

my $fasta;
my @splitchunk;
my $sequence;
$/ = '>';
while(not eof FASTA){
	$fasta = <FASTA>; 
	$fasta=~s/\>//g;
	@splitchunk=split /\n/, $fasta;
	$sequence=@splitchunk[1];
	if (length($sequence) <= $maxlength && length($sequence) >= $minlength){
		print STDOUT "\>".$fasta;
			}
	else{next;}
}
	
close(OUTFILE);
