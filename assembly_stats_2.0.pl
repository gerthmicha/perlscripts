#!/usr/bin/perl
use Getopt::Long;

# Definiert die min_contig length, wenn nicht angegeben, dann = 0
my $min_contig_length=0;
my $plots=0;
my $pdf=0;
my $compare=0;
GetOptions('min_contig_length=i'	=> \$min_contig_length,
	 'pdf'			=> \$pdf,
	 'compare'		=> \$compare	);



# Inputdatei
my $file = $ARGV[0];

# Präfix für Outputdateien
my $prefix = $file;
$prefix =~s/\.fa.*//g;
																
if (!defined $ARGV[0]){
print "\nThis script will calculate and display basic assembly statistics.\n\nUSAGE\t perl assembly_stats.pl [OPTIONS] assembly.fasta [assembly2.fasta]\nOPTIONS\n   --min_contig_length [N]\tminimal size of contigs to be included in statistics (optional)\n   --pdf\t\t\tgenerate a PDF file containing three descriptive plots (requires R installation in system path)\n   --compare\t\t\tcalculate assembly statistics for two assemblies in parallel\n";

}

open (INFILE, '<', $file) or die "\n";

my $file1 = $ARGV[1];
if ($compare==1){
	open (INFILE1, '<', $file1) or die "\nERROR: '--compare' Path to second assembly file missing \n\n";
	}
my $prefix1 = $file1;
$prefix1 =~s/\.fa.*//g;


# Fasta-Assembly einlesen und in @seqs Array speichern
my $linecount;
my @seqs;
my $sequence;
$linecount = -1;
while (my $line = <INFILE>){
	chomp $line;					# chomp through input file line by line
  	if ($line=~ /\>/g){					# search for > with regexpr, if present, write name into @seqs
  		$linecount++;				# number of sequence is counted
		$sequence=undef;				# important: reset $sequence for each new sequence!		
	}
	else {						# if > not present, append each line of sequence 
		$seqs[$linecount] = $sequence.= uc($line);	# then store in array with sequence index
	}
		
}
close (INFILE);

# Array der Größe nach sortieren
my@sortseq;
@sortseq = sort {length $b <=> length $a} @seqs;

# Löschen aller contigs < min_contig_length

if($min_contig_length > 0){
	my $index = -1;
	foreach my $contig(@sortseq){
		$index++;
		if (length $contig < $min_contig_length){
		last;
		}	
	}
	delete @sortseq[$index..(scalar @sortseq)-1] ;
}


my @gccount;
my $contigcounter = 0;	
my $atcontig;									
my $totallength = 0;
my @alllengths;
my @NX;
my $nxlength;
my $Nscalar;

# GC-Values
foreach my $contig(@sortseq){					# loop durch jeden Contig
	$contigcounter++;
	$totallength = $totallength + length $contig;		# kumulative Länge wird 1x je Loop berechnet
	push(@alllengths, $totallength);
	$atcontig = $contig =~ tr/[gGcC]//;			# löschen aller GCs im jeweiligen contig
	push(@gccount, $atcontig / length $contig);		# einzelne GC Werte werden in Array geschrieben
	}	
my $totallength2 = $totallength;

if ($compare==0){
# zusätzlich Berechnung von N50, N75, N25
my $Nscalar = 0;
foreach my $contig(@sortseq){
	$Nscalar += length $contig;
	if ($Nscalar >= $totallength*0.75){
	$Nscalar =~ s/(\d)(?=(\d{3})+(\D|$))/$1\,/g;
	print "\nN75\t\t\t"; 
	printf "%20s", length $contig;
	last;
	}
}

$Nscalar = 0;
foreach my $contig(@sortseq){
	$Nscalar += length $contig;
	if ($Nscalar >= $totallength*0.5){
	$Nscalar =~ s/(\d)(?=(\d{3})+(\D|$))/$1\,/g;
	print "\nN50\t\t\t"; 
	printf "%20s", length $contig;
	last;
	}	
}

$Nscalar = 0;
foreach my $contig(@sortseq){
	$Nscalar += length $contig;
	if ($Nscalar >= $totallength*0.25){
	$Nscalar =~ s/(\d)(?=(\d{3})+(\D|$))/$1\,/g;
	print "\nN25\t\t\t"; 
	printf "%20s", length $contig;
	last;
	}	
}
}

my $assembly1_N75;
my $assembly1_N50;
my $assembly1_N25;
my @assembly1;
my $Nscalar = 0;
foreach my $contig(@sortseq){
	$Nscalar += length $contig;
	if ($Nscalar >= $totallength*0.75){
	$Nscalar =~ s/(\d)(?=(\d{3})+(\D|$))/$1\,/g;
	#print "N75\t\t\t"; 
	#printf "%20s", length $contig;
	$assembly1_N75 = length $contig;
	push (@assembly1, $assembly1_N75);
	last;
	}
}

$Nscalar = 0;
foreach my $contig(@sortseq){
	$Nscalar += length $contig;
	if ($Nscalar >= $totallength*0.5){
	$Nscalar =~ s/(\d)(?=(\d{3})+(\D|$))/$1\,/g;
	#print "\nN50\t\t\t"; 
	#printf "%20s", length $contig;
	$assembly1_N50 = length $contig;
	push (@assembly1, $assembly1_N50);
	last;
	}	
}

$Nscalar = 0;
foreach my $contig(@sortseq){
	$Nscalar += length $contig;
	if ($Nscalar >= $totallength*0.25){
	$Nscalar =~ s/(\d)(?=(\d{3})+(\D|$))/$1\,/g;
	#print "\nN25\t\t\t"; 
	#printf "%20s", length $contig;
	$assembly1_N25 = length $contig;
	push (@assembly1, $assembly1_N25);
	last;
	}	
}


sub average {
my @array = @_; # save the array passed to this function
my $sum; # create a variable to hold the sum of the array's values
foreach (@array) { $sum += $_; } # add each element of the array 
# to the sum
return $sum/@array; # divide sum by the number of elements in the
# array to find the mean
}

my $avggc = sprintf('%.2f%%', 100* average(@gccount));
$totallength =~ s/(\d)(?=(\d{3})+(\D|$))/$1\,/g;
my $ncontigs = scalar(@sortseq);
$ncontigs  =~ s/(\d)(?=(\d{3})+(\D|$))/$1\,/g;
my $longest = length $sortseq[0];
$longest =~ s/(\d)(?=(\d{3})+(\D|$))/$1\,/g;

if($compare==0){
	print "\nNumber of contigs\t"; 
	printf "%20s", $ncontigs;
	print "\nLongest contig\t\t";
	printf "%20s", $longest;
	print "\nTotal assembly size\t";
	printf "%20s", $totallength;
	print "\nAverage GC-content\t";
	printf "%20s", $avggc;
	print "\n\n";
	
# Plots with R
my @Rprefix;
$Rprefix[0] = $prefix;


if($pdf==1){
	$count = -1;
	$Nscalar = 0;
	while($count<501){							 
		$count++;	
		$percent = $count/500;
			$Nscalar = 0;
		foreach my $contig(@sortseq){													
			$Nscalar += length $contig;
				if ($Nscalar >= $totallength2*$percent){
				$NX[$count] = length $contig;
				last;
				}
			}
		}
use Statistics::R;
	my $R = Statistics::R->new();
	$R->set('gcvalues', \@gccount);
	$R->set('alllengths', \@alllengths);
	$R->set('NX', \@NX);
	$R->set('prefix', \@Rprefix);
	$R->run(q`myhist <- hist(gcvalues, breaks=100, plot=F)`); 
	$R->run(q`pdf(file=paste(prefix,"_plots.pdf",sep=""), width=7, height=12)`);
	$R->run(q`par(mfrow=c(3,1))`);
	$R->run(q`par(oma=c(0.5,0.5,0.5,0.5))`);
	$R->run(q`par(las=1)`);
	$R->run(q`multiplier <- myhist$counts / myhist$density`);
	$R->run(q`mydensity <- density(gcvalues)`);
	$R->run(q`mydensity$y <- mydensity$y * multiplier[1]`);
	$R->run(q`plot(myhist, xlab="%GC", ylab="",main="Histogram of GC-content")`);
	$R->run(q`lines(mydensity, col="blue")`);
	$R->run(q`plot(alllengths, type="l", xlab="#contig", ylab="", main="Cumulative contig length", col="blue")`);
	$R->run(q`plot(NX, type="s", xlab="", ylab="", main="Nx", axes=FALSE, col="blue")`);
	$R->run(q`box()`);
	$R->run(q`axis(side=2)`);
	$R->run(q`axis(side=1, at=seq(0,500,50), labels=seq(0,100,10))`);
	$R->run(q`dev.off()`);
}
}


#####################                       
### BEI 2 DATEIEN ###     
#####################

if ($compare==1){

# Fasta-Assembly Nummer 2 einlesen und in @seqs Array speichern
my $linecount1;
my @seqs1;
my $sequence1;
$linecount1 = -1;
while (my $line1 = <INFILE1>){
	chomp $line1;					# chomp through input file line by line
  	if ($line1=~ /\>/g){					# search for > with regexpr, if present, write name into @seqs
  		$linecount1++;				# number of sequence is counted
		$sequence1=undef;				# important: reset $sequence for each new sequence!		
	}
	else {						# if > not present, append each line of sequence 
		$seqs1[$linecount1] = $sequence1.= uc($line1);	# then store in array with sequence index
	}
		
}
close (INFILE1);

# Array der Größe nach sortieren
my@sortseq1;
@sortseq1 = sort {length $b <=> length $a} @seqs1;

# Löschen aller contigs < min_contig_length
if($min_contig_length > 0){
	my $index1 = -1;
	foreach my $contig1(@sortseq1){
		$index1++;
		if (length $contig1 < $min_contig_length){
		last;
		}	
	}	
	delete @sortseq1[$index1..(scalar @sortseq1)-1] ;
}


my @gccount1;
my $contigcounter1 = 0;	
my $atcontig1;									
my $totallength1 = 0;
my @alllengths1;
my @NX1;
my $nxlength1;
my $Nscalar1;

foreach my $contig1(@sortseq1){					# loop durch jeden Contig
	$contigcounter1++;
	$totallength1 = $totallength1 + length $contig1;		# kumulative Länge wird 1x je Loop berechnet
	push(@alllengths1, $totallength1);
	$atcontig1 = $contig1 =~ tr/[gGcC]//;			# löschen aller GCs im jeweiligen contig
	push(@gccount1, $atcontig1 / length $contig1);		# einzelne GC Werte werden in Array geschrieben
	}
	

my $totallength12 = $totallength1;

print "\n\t\t\t"; 
printf "%20s", $prefix;
print "\t";
printf "%20s", $prefix1;
	
# zusätzlich Berechnung von N50, N75, N25
my $Nscalar1 = 0;
foreach my $contig1(@sortseq1){
	$Nscalar1 += length $contig1;
	if ($Nscalar1 >= $totallength1*0.75){
	$Nscalar1 =~ s/(\d)(?=(\d{3})+(\D|$))/$1\,/g;
	print "\nN75\t\t\t"; 
	printf "%20s", $assembly1[0];
	print "\t";
	printf "%20s", length $contig1;
	last;
	}	
}
my $Nscalar1 = 0;
foreach my $contig1(@sortseq1){
	$Nscalar1 += length $contig1;
	if ($Nscalar1 >= $totallength1*0.50){
	$Nscalar1 =~ s/(\d)(?=(\d{3})+(\D|$))/$1\,/g;
	print "\nN50\t\t\t"; 
	printf "%20s", $assembly1[1];
	print "\t";
	printf "%20s", length $contig1;
	last;
	}
}
my $Nscalar1 = 0;
foreach my $contig1(@sortseq1){
	$Nscalar1 += length $contig1;
	if ($Nscalar1 >= $totallength1*0.25){
	$Nscalar1 =~ s/(\d)(?=(\d{3})+(\D|$))/$1\,/g;
	print "\nN25\t\t\t"; 
	printf "%20s", $assembly1[2];
	print "\t";
	printf "%20s", length $contig1;
	last;
	}
}

my $avggc1 = sprintf('%.2f%%', 100* average(@gccount1));
$totallength1 =~ s/(\d)(?=(\d{3})+(\D|$))/$1\,/g;
my $ncontigs1 = scalar(@sortseq1);
$ncontigs1  =~ s/(\d)(?=(\d{3})+(\D|$))/$1\,/g;
my $longest1 = length $sortseq1[0];
$longest1 =~ s/(\d)(?=(\d{3})+(\D|$))/$1\,/g;

	print "\nNumber of contigs\t"; 
	printf "%20s", $ncontigs;
	print "\t";
	printf "%20s", $ncontigs1;
	print "\nLongest contig\t\t";
	printf "%20s", $longest;
	print "\t";
	printf "%20s", $longest1;
	print "\nTotal assembly size\t";
	printf "%20s", $totallength;
	print "\t";
	printf "%20s", $totallength1;
	print "\nAverage GC-content\t";
	printf "%20s", $avggc;
	print "\t";
	printf "%20s", $avggc1;
	print "\n\n";

# Plots with R
my @Rprefix;
$Rprefix[0] = $prefix;
my @Rprefix1;
$Rprefix1[0] = $prefix1;

if($pdf==1){
	$count = -1;
	$Nscalar = 0;
	while($count<501){							 
		$count++;	
		$percent = $count/500;
			$Nscalar = 0;
		foreach my $contig(@sortseq){													
			$Nscalar += length $contig;
				if ($Nscalar >= $totallength2*$percent){
				$NX[$count] = length $contig;
				last;
				}
			}
		}
	$count1 = -1;
	$Nscalar1 = 0;
	while($count1<501){							 
		$count1++;	
		$percent1 = $count1/500;
			$Nscalar1 = 0;
		foreach my $contig1(@sortseq1){													
			
			$Nscalar1 += length $contig1;
				if ($Nscalar1 >= $totallength12*$percent1){
				$NX1[$count1] = length $contig1;
				last;
				}
			}
		}
use Statistics::R;
	# Set variables, read from perl
	my $R = Statistics::R->new();
	$R->set('gcvalues', \@gccount);
	$R->set('alllengths', \@alllengths);
	$R->set('NX', \@NX);
	$R->set('prefix', \@Rprefix);
	$R->set('gcvalues1', \@gccount1);
	$R->set('alllengths1', \@alllengths1);
	$R->set('NX1', \@NX1);
	$R->set('prefix1', \@Rprefix1);
	# PDF settings
	$R->run(q`pdf(file="assembly_stats.pdf", width=7, height=12)`);
	$R->run(q`par(mfrow=c(3,1))`);
	$R->run(q`par(oma=c(0.5,0.5,0.5,0.5))`);
	$R->run(q`par(las=1)`);
	# GC density plot
	$R->run(q`mydens <- density(gcvalues)`); 
	$R->run(q`mydens1 <- density(gcvalues1)`);
	$R->run(q`maxx <- max(c(mydens$x, mydens1$x))`);
	$R->run(q`minx <- min(c(mydens$x, mydens1$x))`);
	$R->run(q`maxy <- max(c(mydens$y, mydens1$y))`);
	$R->run(q`plot(mydens, xlim=c(minx, maxx), ylim=c(0, maxy), xlab="%GC", ylab="",main="Density plot of GC-content", col=rgb(0,0,1,1/4))`);
	$R->run(q`polygon(mydens, col=rgb(0,0,1,1/4), border=rgb(0,0,1,1/4))`);
	$R->run(q`polygon(mydens1, col=rgb(1,0,0,1/4), border=rgb(1,0,0,1/4))`);
	$R->run(q`legend("topright", c(prefix, prefix1), fill=c(rgb(0,0,1,1/4), rgb(1,0,0,1/4)), border="NA", bty="n")`);
	$R->run(q`grid()`);
	# Cumulative length plot
	$R->run(q`maxy <- max(c(alllengths, alllengths1))`);
	$R->run(q`maxx <- max(c(length(alllengths), length(alllengths1)))`);
	$R->run(q`plot(alllengths, type="l",xlim=c(0,maxx*1.1), ylim=c(0,maxy*1.1), xlab="#contig", ylab="", main="Cumulative contig length", col="blue")`);
	$R->run(q`lines(alllengths1, col="red")`);
	$R->run(q`legend("bottomright", c(prefix, prefix1), col=c(rgb(0,0,1), rgb(1,0,0)), border="NA", bty="n", lwd=2)`);
	$R->run(q`grid()`);
	# Nx plot
	$R->run(q`maxy <- max(c(NX, NX1))`);
	$R->run(q`plot(NX, type="s", ylim=c(0, maxy*1.1), xlab="", ylab="", main="Nx", axes=FALSE, col="blue")`);
	$R->run(q`lines(NX1, type="s", col="red")`);
	$R->run(q`box()`);
	$R->run(q`axis(side=2)`);
	$R->run(q`axis(side=1, at=seq(0,500,50), labels=seq(0,100,10))`);
	$R->run(q`grid()`);
	$R->run(q`legend("topright", c(prefix, prefix1), col=c(rgb(0,0,1), rgb(1,0,0)), border="NA", bty="n", lwd=2)`);
	$R->run(q`dev.off()`);
}

}





