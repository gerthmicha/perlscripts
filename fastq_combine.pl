#!/usr/bin/perl
use strict; 
use Getopt::Long;

# defines --fasta option (output as fasta instead of fastq)
# defines --no-check option (don't check for equal lengths of input files)
my $fasta;
my $check;
GetOptions('fasta'    => \$fasta,
	 'no-check' => \$check);

# input fastq-files
my $inputfastq1 = $ARGV[0];									
my $inputfastq2 = $ARGV[1];
my $prefix = $inputfastq1;
$prefix=~s/_(read|r|)(1|2).(fq|fastq)//;

open (FASTQ1 , '<' , $inputfastq1) or die "\nCreate a single file out of paired end read files\nUSAGE:\tperl fastq_combine.pl [--fasta --no-check] readfile_1.fastq readfile_2.fastq\n\n";
open (FASTQ2 , '<' , $inputfastq2) or die "\n";

# Check if read files are of same length
unless ($check==1){
	my$length1=`wc -l $inputfastq1`;
	my$length2=`wc -l $inputfastq2`;
	$length1=~s/\s.+//g;
	$length2=~s/\s.+//g;
	if($length1 != $length2){die "\nInput files have unequal length!\n\n";} 
	}
	
my $checkline1;
my $checkline2;
# when --fasta option is invoked
if($fasta==1){
	# create output file and check if it alreads exists
	my $outputfile=$prefix."_comb.reads.fas";
	if(-e $outputfile){
		print "\n$outputfile already exists! Overwrite? (Y|n) ";
   		chomp(my $input = <STDIN>);
		if ($input eq "Y"){
			`rm -rvf $outputfile`;
			print "\noverwriting\n";
			}
		else{
			die"\nexiting!\n"}
		}
	open (OUTFILE , '>>', $outputfile);
	my $linecounter=0;
	my $counter=-1;
	my @fastq1;
	my @fastq2;
	my $fastq1;
	my $fastq2;
	my$fastq1line;
	my$fastq2line;
	while(not eof FASTQ1 and not eof FASTQ2){
		$fastq1 = <FASTQ1>; 
		$fastq2 = <FASTQ2>;
		push(@fastq1,$fastq1);
		push(@fastq2,$fastq2);
		$linecounter++;
		$counter++;
		if($counter == 3){
			# replace '@' from fastq-id with '>'
			$fastq1line=$fastq1[0];
			$fastq1line=~s/@/>/g;
			$fastq2line=$fastq2[0];
			$fastq2line=~s/@/>/g;
			# perform name check only when option is set
			unless($check==1){
				$checkline1=$fastq1line;
				$checkline1=~s/\/1//g;
				$checkline2=$fastq2line;
				$checkline2=~s/\/2//g;
				if($checkline1 ne $checkline2){
					my $wrongline=$linecounter-3;
					die "\nERROR: Read names do not match!\n       Check input files line number $wrongline\n\n"}
				}
			# Print the first 2 lines of file (id + sequence)
			print OUTFILE "$fastq1line$fastq1[$counter-2]";
			print OUTFILE "$fastq2line$fastq2[$counter-2]";
			$counter = -1;
			undef @fastq1;
			undef @fastq2;
			}
		}
	}
else{
	# create output file and check if it alreads exists
	my $outputfile=$prefix."_comb.reads.fq";
	if(-e $outputfile){
		print "\n$outputfile already exists! Overwrite? (Y|n) ";
   		chomp(my $input = <STDIN>);
		if ($input =~/Y/){
			`rm -rf $outputfile`;
			print "\noverwriting\n";
			}
		else{
			die"\nexiting!\n\n"}
		}
	open (OUTFILE , '>>', $outputfile);
	my $linecounter=0;
	my $counter=-1;
	my @fastq1;
	my @fastq2;
	my $fastq1;
	my $fastq2;
	while(not eof FASTQ1 and not eof FASTQ2){
		$fastq1 = <FASTQ1>; 
		$fastq2 = <FASTQ2>;
		push(@fastq1,$fastq1);
		push(@fastq2,$fastq2);
		$linecounter++;
		$counter++;
		if($counter == 3){
			# perform name check only when option is set
			unless($check==1){
				$checkline1=$fastq1[0];
				$checkline1=~s/\/1//g;
				$checkline2=$fastq2[0];
				$checkline2=~s/\/2//g;
				if($checkline1 ne $checkline2){
					my $wrongline=$linecounter-3;
					die "\nERROR: Read names do not match!\n       Check input files line number $wrongline\n\n"}
				}
			print OUTFILE "$fastq1[$counter-3]$fastq1[$counter-2]$fastq1[$counter-1]$fastq1[$counter]";
			print OUTFILE "$fastq2[$counter-3]$fastq2[$counter-2]$fastq2[$counter-1]$fastq2[$counter]";
			$counter = -1;
			undef @fastq1;
			undef @fastq2;
			}
		}
	}
	
close(OUTFILE);	


