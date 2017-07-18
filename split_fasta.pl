#!/usr/bin/perl 
use strict; 

my $inputfasta = $ARGV[0];	
my$prefix = $inputfasta;
$prefix =~s/(.f.*)//;
open (FASTA, '<', $inputfasta) or die "This sript will extract paired-end reads from a fasta file and create single files for forward, reverse and unpaired reads.\nUSAGE:\tperl split_fasta.pl input_fasta\n";
open (OUTFASTA1 ,'>', $prefix."_1.fas");
open (OUTFASTA2 ,'>', $prefix."_2.fas");
open (OUTFASTA3 ,'>', $prefix."_unpaired.fas");
my $seqcount =-1;
my @seqids;
my @seqs;
my $sequence;
while (my $fastaline = <FASTA>){								
	chomp $fastaline;
	# liest Fasta-Datei Zeile für Zeile
	if ($fastaline=~/\>/g){
	$seqcount++;
	push(@seqids, $fastaline);
	$sequence=undef;}
	# wenn ">" gefunden wird, speichere Zeile in Namens-Array
	else{
	$seqs[$seqcount]=$sequence.=$fastaline;
	}
	# ansonsten speichere in Sequenz-Array
}
my $counter=-1;
foreach my $ID(@seqids){
	$counter++;
	if ($ID=~/\/1/g){
		print OUTFASTA1 "$seqids[$counter]\n$seqs[$counter]\n"
		}
	elsif ($ID=~/\/2/g){
		print OUTFASTA2 "$seqids[$counter]\n$seqs[$counter]\n"
		}	
	else {    print OUTFASTA3 "$seqids[$counter]\n$seqs[$counter]\n"
		}
	}


