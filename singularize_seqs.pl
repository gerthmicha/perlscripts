#!/usr/bin/perl


my $concatfasta = $ARGV[0];

open (FASTA , '<' , $concatfasta) or die "\nThis script creates single sequence files from any multi-sequence fasta file. \nPlease specify path to fasta file!\n\n";	

my $linecount = -1;
my @names;
my @seqs;
my $sequence;

while (my $line = <FASTA>) {
  	chomp $line;						# chomp through input file line by line
  	if ($line=~ /\>/g){						# search for > with regexpr, if present, write name into @seqs
  		$linecount++;					# number of sequence is counted
		$names[$linecount]=$line;
		$names[$linecount]=~s/\>//;			# use sequence number as index of arrays 
		$sequence=undef;					# important: reset $sequence for each new sequence!		
		}
	else{
		$seqs[$linecount] = $sequence.= uc($line);
		}
}


close(FASTA);

my $seqcounter=-1;
my $genecounter=-1;

foreach my $element(@names){
	$seqcounter++;
	open (OUTFASTA, '>', $element.'.fas');
	print OUTFASTA ">$names[$seqcounter]\n$seqs[$seqcounter]\n";
	close (OUTFASTA);
	}
	

	


