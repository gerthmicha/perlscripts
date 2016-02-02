#!/usr/bin/perl 
use Data::Dumper; 
use List::Util qw( min max );

my $concatfasta = $ARGV[0];
my $partitionfile = $ARGV[1];

if(!defined $ARGV[0] && !defined $ARGV[1]){
	print"\nThis script will create single fasta files out of a larger alignment based on a partitioning scheme.\nUSAGE:\t\tperl split_partitions.pl [fasta file] [partition file]\n\nExample of a partition file:\n\npartition1=1-100 201-300\npartition2=101-200\n...\n\n";
	}

else{

open (FASTA , '<' , $concatfasta) or die "\n>FILE MISSING<\n\nPlease specify path to concatenated fasta file!\n\n";	

my $linecount = -1;
my @names;
my @seqs;
my $sequence;
my @seqlengths;


while (my $line = <FASTA>) {
  	chomp $line;						# chomp through input file line by line
  	if ($line=~ /\>/g){						# search for > with regexpr, if present, write name into @seqs
  		$linecount++;					# number of sequence is counted
		$names[$linecount]=$line;				# use sequence number as index of arrays 
		$sequence=undef;					# important: reset $sequence for each new sequence!		
		}
	else{
		$seqs[$linecount] = $sequence.= uc($line);
		push @seqlengths, length $seqs[$linecount];
		}
	

}
$min = min @seqlengths;
$max = max @seqlengths;
if ($min != $max){
	die "\n>ERROR WHEN READING FASTA FILE<\n\nSequences are not of the same length. Please make sure sequences are aligned!\n\n"};
my $sequencenumber=scalar @names;


close(FASTA);


open(PARTITION, '<', $partitionfile) or die "\n>FILE MISSING<\n\nPlease specify path to partition file!\n\n";

my @genenames;
my @begins;
my @ends;
my @name;
my $x;
my $y;


my $seqcounter=-1;
my $singlegenecounter=-1;
my $partitioncounter=-1;
my $singlegene;
my $printseq;
my @joinedpartition;

my $all_partitions;
while (my $line=<PARTITION>){
	chomp $line;	
	$partitioncounter++;
	$seqcounter=-1;
	($x, $y) = split /=/, $line;
	push(@genenames, $x);
	@begins = ($y =~ /(\d+)-/g);
	@ends = ($y =~ /-(\d+)/g);
	foreach my $element(@seqs){
		$singlegenecounter=-1;
		$seqcounter++;
		foreach my $start(@begins){
			$singlegenecounter++;
			$singlegene = substr($seqs[$seqcounter], $begins[$singlegenecounter]-1, $ends[$singlegenecounter]-$begins[$singlegenecounter]+1);
			push(@joinedpartition, $singlegene);
			$all_partitions.=$singlegene;
			$singlegene=undef;
		}
		$printseq = join("", @joinedpartition);
		open(OUTFASTA, '>>', $genenames[$partitioncounter].'.fas');
		print OUTFASTA $names[$seqcounter],"\n",$printseq,"\n";	
		close(OUTFASTA);
		@joinedpartition=undef;
	}
	@begins=undef;
	@ends=undef;
	$x=undef;
	$y=undef;
	}	

print "\nnumber of partitions: ".scalar(@genenames), "\n";
my $partitionlength=length $all_partitions;
my $alignmentlenght = $partitionlength / $sequencenumber;
if($alignmentlenght < $max){
	print "\n>WARNING<\nNot all positions of fasta file were assigned to a partition. Please check your partition file!\nNumber of positions in alignment: $max\nNumber of positions assigned to partitions: $alignmentlenght\n\n";
}
elsif($alignmentlenght > $max){
	print "\n>WARNING<\nSome positions of the fasta file were assigned to more than one partition. Please check your partition file!\nNumber of positions in alignment: $max\nNumber of positions assigned to partitions: $alignmentlenght\n\n";

} 

close(PARTITION);

}

