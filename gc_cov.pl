#!/usr/bin/perl
use Getopt::Long qw(GetOptions);
use Data::Dumper;

my $infile;
my $taxfile;
my $ntaxa;

GetOptions('ntaxa=i'  => \$ntaxa,
'assembly=s' => \$infile,
'taxonomy=s' => \$taxfile);

if(!defined $taxfile){die "\nThis script will draw simple GC coverage plots from SPAdes assembly files. It uses the information on kmer coverage and contig lengths given in the SPAdes assembly files. \n»Please note that the coverage therefore does not correspond to actual nucleotide coverage, but to kmer coverage as estimated by SPAdes with the largest kmer used!«\nRequires Perl module 'Statistics::R' and R packages 'ggplot2' and 'viridis'.\n\nUSAGE: perl gc_cov.pl assembly.fasta [taxonomy.txt]\n\nFormat for (optional) taxonomy file:\ncontigname1\ttaxonname\ncontigname2\ttaxonname\n...\n\n"};


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
  		$line =~s/>//g;;						# number of sequence is counted
		$names[$linecount]=$line;					# use sequence number as index of arrays 
		$sequence=undef;						# important: reset $sequence for each new sequence!		
		}
		else {								# if > not present, append each line of sequence 
		$seqs[$linecount] = $sequence.= uc($line);			# then store in array with sequence index
		}
}
close(INFILE);

my @lengths;
my @coverage;
my $namecount = -1;
my %taxonomy;
my %occurence;
foreach my $name(@names){
	$namecount++;
	my @fields = split /_/, $name;
	$lengths[$namecount] = $fields[3];
	$coverage[$namecount] = $fields[5];
	}

my @gcvalues;
my $atseq;
my $gcseq;
my $seqcounter=-1;
foreach my $seq(@seqs){
	$seqcounter++;					
	$atseq = $seq =~ tr/[gGcC]//;			# löschen aller GCs im jeweiligen contig
	
	$gcvalues[$seqcounter] = $gcseq = $atseq / length $seq; 
	}


if(defined $taxfile){
	open(TAXFILE, '<', $taxfile);
	while (my $taxline = <TAXFILE>){
	chomp $taxline;
	my @taxfields = split /\t/, $taxline;
	$occurence{@taxfields[1]}++;
	if(defined($taxonomy{$taxfields[0]})){
		next;
		}
	else{$taxonomy{$taxfields[0]} = $taxfields[1];
		}
	}	
}
my %wanted;
if(defined $ntaxa){
	my @sorted = sort { $occurence{$b} <=> $occurence{$a} } keys %occurence;
	my @wanted = @sorted[0..($ntaxa-1)];
	foreach my $element(@wanted){
	$wanted{$element} = undef;
	}
}
else{%wanted = %occurence};


my @taxarray;
my $newcounter=-1;
foreach my $name(@names){
	$newcounter++;
	if(exists($taxonomy{$name}) && exists($wanted{$taxonomy{$name}})){
		$taxarray[$newcounter] = $taxonomy{$name};
	}
	else{$taxarray[$newcounter] = "unknown"};
}


use Statistics::R;
	# Set variables, read from perl
	my $R = Statistics::R->new();
	$R->set('gcvalues', \@gcvalues);
	$R->set('Length', \@lengths);
	$R->set('coverage', \@coverage);
	$R->set('Taxonomy', \@taxarray);
	$R->run(q`library(ggplot2)`);
	$R->run(q`library(viridis)`);
	$R->run(q`colorpal<- viridis_pal(option = "D")(length(unique(Taxonomy)))`);
	$R->run(q`pdf(file= "gc.cov.plot.pdf", paper="a4r", width=10, height=8)`);
	$R->run(q`if(max(coverage)>1000*min(coverage)){qplot(gcvalues, coverage, size=Length, alpha=0.6, colour=Taxonomy, stroke=0)+theme_light()+scale_colour_manual(values=colorpal)+scale_alpha(guide = 'none')+ylab("Kmer coverage")+xlab("Proportion GC")+scale_y_log10()+ guides(colour = guide_legend(override.aes = list(size=5)))}`);
	$R->run(q`if(max(coverage)<=1000*min(coverage)){qplot(gcvalues, coverage, size=Length, alpha=0.6, colour=Taxonomy, stroke=0)+theme_light()+scale_colour_manual(values=colorpal)+scale_alpha(guide = 'none')+ylab("Kmer coverage")+xlab("Proportion GC")+ guides(colour = guide_legend(override.aes = list(size=5)))}`);
	$R->run(q`dev.off()`);

