#!/usr/bin/perl

my $infile = $ARGV[0];
if(!defined $ARGV[0]){die "\nThis script calculates GC values from each sequence of a given fasta file.\nUSAGE: perl GC.pl input.fasta\n\n"};

# Fasta-Assembly einlesen und in @seqs Array speichern
my $linecount = -1;
my @names;
my @seqs;
my $sequence;
open(INFILE, '<', $infile);

while (my $line = <INFILE>) {
  	chomp $line;								# chomp through input file line by line
  		if ($line=~ /\>/g){						# search for > with regexpr, if present, write name into @seqs
  		$linecount++;
  		$line =~s/>//g;;							# number of sequence is counted
		$names[$linecount]=$line;				# use sequence number as index of arrays 
		$sequence=undef;						# important: reset $sequence for each new sequence!		
		}
		else {									# if > not present, append each line of sequence 
		$seqs[$linecount] = $sequence.= uc($line);	# then store in array with sequence index
		}
}
close(INFILE); 
my $atseq;
my $seqcounter=-1;
foreach my $seq(@seqs){
	$seqcounter++;					
	$atseq = $seq =~ tr/[gGcC]//;			# löschen aller GCs im jeweiligen contig
	print $names[$seqcounter],"\t", $atseq / length $seq, "\n";		# berechnen des GC Gehalts und schreiben in Outputdatei
	}
