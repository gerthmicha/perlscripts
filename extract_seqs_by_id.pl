#!/usr/bin/perl
use strict;
use Getopt::Long;

## Erstellt aus einer Fasta-Datei eine neue, nur mit gewünschten Sequenzen. 
## Benötigt zwei Pfade zu Dateien: 1) Fasta-Datei 2) Datei mit gewünschten (bzw ungewünschten bei --exclude) Sequenzen (jede ID in extra Zeile) Die neue Fasta-Datei wird unter "outfile.fas" abgespeichert
## Kommentare stehen jeweils UNTER den Befehlen

my $exclude;
GetOptions('exclude'    => \$exclude);
# definiert die --exclude Option

my $inputfasta = $ARGV[0];									
my $wanted_ids = $ARGV[1];									 
# definiert die Inputdateien 

open (FASTA , '<' , $inputfasta) or die "\nThis script will extract those sequences from a fasta file that match (or do not match) provided IDs\n\nUSAGE:\tperl extract_seqs_by_id.pl [--exclude] input.fasta IDs.txt (one ID per line)\n\t--exclude creates fasta file containing all sequences that DO NOT match provided IDs\n\t(default: create fasta file containing all sequences that DO match provided IDs)\n\n";
open (BLAST , '<' , $wanted_ids) or die "Please provide \nA) Path to fasta file from which to extract sequences\nB) Path to file that contains all IDs to be searched for (each in a single line)\n";

my $prefix = $inputfasta;
$prefix=~s/\.fa.*//;
my $outputfile=$prefix."_OUT.fas";
	if(-e $outputfile){
		print "\n$outputfile already exists! Overwrite? (Y|n) ";
	   	chomp(my $input = <STDIN>);
	   		if ($input eq "Y"){
			`rm -rvf $outputfile`;
			print "overwriting...\n\n";
			}
		else{
			die"\nexiting!\n"
			}
		}
open (OUTFILE, '>>', $outputfile);	
# Checkt, ob es schon eine Datei mit unserem Outputnamen gibt, falls ja Abfrage ob überschrieben werden soll


my $idcounter=0;						
my %id;												


while (my $blastline = <BLAST>){								
	chomp $blastline;
	$blastline=~s/\>//g;
	$blastline=~s/\\1//;
	$blastline=~s/\\2//;
	$idcounter++;
	print"$idcounter\tIDs read from $wanted_ids\r";										
	$id{$blastline}=1;									
	}

# Dieser Loop speichert alle unsere IDs aus der Datei in einen Hash, den wir später zum Suchen verwenden (doppelte Namen in ID Datei sind also ok)


my $fasta;
my @fasta;
my @splitchunk;
my $seqname;
my $counter=0;
my $totalcounter=0;
if($exclude==1){	
# falls --exclude gewählt wurde
	$/ = '>';
	while(not eof FASTA){
	# Einlesen der Fastadatei
		$fasta = <FASTA>; 
		$totalcounter++;
		$fasta=~s/\>//g;
		@splitchunk=split /\n/, $fasta;
		$seqname=@splitchunk[0];
		$seqname=~s/\\1//;
		$seqname=~s/\\2//;
		if (!$id{$seqname}){
			$counter++;
			if ($counter>1){
				print OUTFILE "\>".$fasta;
				}
				
			}
		}
	print "\n$totalcounter\tsequences in $inputfasta\n",$totalcounter-$counter,"\tsequences removed\n==>\tNew file with ",$counter," sequences written to $outputfile\n\n"
	}
	
			
else{
# ohne --exclude Option
	$/ = '>';
	while(not eof FASTA){
		$fasta = <FASTA>; 
		$totalcounter++;
		$fasta=~s/\>//g;
		@splitchunk=split /\n/, $fasta;
		$seqname=@splitchunk[0];
		$seqname=~s/\\1//;
		$seqname=~s/\\2//;
		if ($id{$seqname}){
			$counter++;
			print OUTFILE "\>".$fasta;
			}	
		}
	my$percentage=sprintf('%.2f', ($counter/$idcounter*100));
	print "\n$totalcounter\tsequences in $inputfasta\n",$counter,"\tof provided IDs found in $inputfasta ($percentage%)\n==>\tNew sequence file written to $outputfile\n\n";
	}
	
		
close(FASTA);
close(BLAST);
close(OUTFILE);
# alles schließen, fertig
