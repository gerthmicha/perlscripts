#!/usr/bin/perl
# extracts longest sequence from fasta-file
use strict; 
my $linecount;
my @files = <*.fa*>;
my @names;
my @seqs;
my $sequence;
mkdir('seqs');
foreach my $file(@files){
	@seqs=undef;
	@names=undef;
	open (INFILE, '<', $file) or die "can't open $file $!";
	my $prefix = $file;
	$prefix =~s/\.fa.*//g;
	open (OUTFILE, '>', 'seqs/'.$prefix.'.fas');
	$linecount = -1;
	while (my $line = <INFILE>){
		chomp $line;					# chomp through input file line by line
  		if ($line=~ /\>/g){					# search for > with regexpr, if present, write name into @seqs
  			$linecount++;				# number of sequence is counted
			$names[$linecount]=$line;			# use sequence number as index of arrays 
			$sequence=undef;				# important: reset $sequence for each new sequence!		
		}
		else {						# if > not present, append each line of sequence 
			$seqs[$linecount] = $sequence.= uc($line);	# then store in array with sequence index
		}
		
		}
	my@sortseq;
	@sortseq = sort {length $b <=> length $a} @seqs;
	print OUTFILE "$names[0]\n","$sortseq[0]\n";
	close (INFILE);
	close (OUTFILE);
}
	
	
print "processed files: \n", join("\n",@files);
