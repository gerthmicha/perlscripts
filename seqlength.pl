#!/usr/bin/perl

my $infile = $ARGV[0];
if(!defined $ARGV[0]){die "\nThis script shows the length of each sequence of a given fasta file.\nUSAGE: perl seqlength.pl input.fasta\n\n"};

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
my $seqcounter=-1;
foreach my $seq(@seqs){
	$seqcounter++;					
	print $names[$seqcounter],"\t", length $seq, "\n";		# berechnen des GC Gehalts und schreiben in Outputdatei
	}
