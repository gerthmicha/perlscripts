#!/usr/bin/perl
use strict;
use Data::Dumper;
my $blastfile = $ARGV[0];
my $cogfile = $ARGV[1];
my $cognamefile = $ARGV[2]; 
# define input files

if(!defined $ARGV[0] && !defined $ARGV[1] && !defined $ARGV[2]){
	print "This script will parse COG information after blasting query proteins against COG proteins.\nUSAGE:\tperl cogparser.pl [BLAST output] [list of orthology domains] [list of COG annotations]\nNOTE:\tCOG files can be downloaded from ftp://ftp.ncbi.nih.gov/pub/COG\n";
die"\n";
	}

# Check if input files were provided, else show usage information	
open (BLAST , '<' , $blastfile) or die "\n>FILE MISSING<\n\nplease specify path to tabular BLAST output!\n\n";
open (COG , '<' , $cogfile) or die "\n>FILE MISSING<\n\nplease specify path to list of orthology domains!\n\n";
open (COGNAME , '<' , $cognamefile) or die "\n>FILE MISSING<\n\nplease specify path to list of COG annotations\n\n";

my @blastline;
my @querynames;
my $hit;
my @hitnames;

while (my $line = <BLAST>) {
# read through BLAST output line by line
  	chomp $line;
  	@blastline=undef; 
  	@blastline = split /\t/, $line;
  	# split at tabs, store query and hit name in arrays
  	if(scalar(@blastline)!=12){
  		die "BADLY FORMATTED BLAST FILE!\nUse '-outfmt 6' option in BLAST+!\n";}
  		# check if BLAST output contains 12 columns- if not, print error message and die  		
  	else{
  	  	push(@querynames,$blastline[0]);
  	  	$hit = $blastline[1];
		$hit =~ s/gi\|//g;
		$hit =~ s/\|ref.*//g;
		push(@hitnames,$hit);
		$hit = undef;
	}
}

close(BLAST);

my @cogline;
my %coghash;

while (my $line = <COG>) {
        chomp $line;
        @cogline=undef;
        @cogline= split /,/, $line;
        $coghash{$cogline[0]} = $cogline[6] ;
}

close(COG);

my @cognameline;
my %cognamehash;

while (my $line = <COGNAME>) {
	chomp $line;
	@cognameline=undef;
	@cognameline= split /\t/, $line;
	$cognamehash{$cognameline[0]} = join(' ',$cognameline[1],$cognameline[2]);
}

#print Dumper(\%cognamehash);


my $counter=-1;
my $cognamekey;
foreach my $element(@querynames){
	$counter++;
	$cognamekey = undef;
	$cognamekey = $coghash{$hitnames[$counter]};
	print $element, "\t", $coghash{$hitnames[$counter]}, "\t", $cognamehash{$cognamekey},"\n";
	
} 





