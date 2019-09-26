#!/usr/bin/perl -w

use strict;
use warnings;  
use Bio::DB::HTS;

my $usage = "Usage $0 <input.bam>\n";
my $infile = shift or die $usage;
my $sam = Bio::DB::HTS->new(-bam  => $infile);
my @chromosomes = $sam->seq_ids;   
print "Read_ID\tChr\tStart\tEnd\tMapped_Length\tCIGAR_String\n";

foreach my $chr (@chromosomes){
   my @alignments = $sam->get_features_by_location(-seq_id => $chr);
   for my $a (@alignments) {
      my $id  = $a->name;
      my $cigar  = $a->cigar_str;
      my $start  = $a->start;
      my $end    = $a->end;
      my $mapped_length = $end-$start;
     print "$id\t$chr\t$start\t$end\t$mapped_length\t$cigar\n";    
}
}
__END__
