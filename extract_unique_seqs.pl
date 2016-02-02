#!/usr/bin/perl
use strict; 
my $inputfasta = $ARGV[0];
									
open (FASTA , '<' , $inputfasta) or die "This script will extract unique sequences from a fasta file. The longest sequence of each unique ID will be printed to a fasta file. \nWhen identical sequences are present, a reduced fasta file containing only unique IDs AND sequences will be printed to another file.\nUSAGE: perl extract_unique_seqs.pl </path/to/fasta/file>\n";
my $outname = $inputfasta;
$outname =~ s/\.fa.?//;
open (OUTFILE, '>', $outname.'_unique.fas') or die "Can't write output!\n";	

						
my @seqids;
my @seqs;	
my $seqcount = -1;
my %seq_hash;
my $current_seq;
my $current_ID;

while(my $fastaline = <FASTA>){								
	chomp $fastaline;
	# read fasta line by line
	if($fastaline=~/^\>/g){
		$seqcount++;
		push(@seqids, $fastaline);
		$current_seq=undef;
		}
	# if '>' present, save line in ID-array
	else{
		$current_ID = pop(@seqids);
		# pop last ID (= the one belonging to the current sequence)
		if(grep{$_ eq $current_ID} @seqids){
		# if current ID is already present in ID-array
			push(@seqids, $current_ID);
			$seqs[$seqcount]=$current_seq.=$fastaline;
			# save sequence to sequence-array
			if(length($current_seq) > length($seq_hash{$current_ID})){
				$seq_hash{$seqids[$seqcount]}=$current_seq;
				}
				# save only in sequence-hash if sequence is longer than the one with identical ID 
			}
		else{
		# if current ID is NOT already present in ID-array
		push(@seqids, $current_ID);
		$current_seq.=$fastaline;
		$seqs[$seqcount]=$current_seq;
		$seq_hash{$seqids[$seqcount]}=$current_seq;
		# save sequence to array & hash
		}
	
	}
	}
close(FASTA);
# Now all sequences with unique IDs are stored in a hash! Shorter sequences with identical IDs were discarded.
# Next step: identify identical sequences in this hash!


my (%seen, %seq_out);
my $identical_counter = 0; 
print "\nThese IDs have identical sequences:\n";

while(my ($k,$v) = each %seq_hash) {
# read through sequence hash, look at key & value pairs
   	if($seen{$v}){
   	# if value (=sequence) is already in our "seen" hash
   		$identical_counter++;
   		# count number of identical sequences
   		my $k1 = $k;
   		my $k2 = $seen{$v};
   		$k1 =~ s/\>//;
   		$k2 =~ s/\>//;
   		print "$k1";
   		print "\t\t\t\t\t";
   		print "$k2\n";
   		# print information on identical sequences
   		}
   	else{
   	$seen{$v} = $k;
   	$seq_out{$k} = $v;
   	# if value (=sequence) is NOT already in our "seen" hash,
   	# store these unique sequences + IDs in another hash
   	}
	}	

			
if($identical_counter > 0){
	# when identical sequences are present
	open (REDFILE, '>', $outname.'_OUT.red.fas') or die "Can't write output!\n";	
	for my $key(sort keys%seq_out){
		print REDFILE "$key\n$seq_out{$key}\n";	
		# print reduced alignment without duplicate sequences 
	}
	if($identical_counter == 1){
	print "\n$identical_counter sequences was identical to another sequence in $inputfasta\nA reduced alignment was written to $outname\_OUT.red.fas\n\n";
	}
	else{print "\n$identical_counter sequences were identical to other sequences in $inputfasta\nA reduced alignment was written to $outname\_OUT.red.fas\n\n";
	}
	# print info to screen
}
else{print "(none)\n";}
close(REDFILE);
for my $keys(sort keys%seq_hash){
	print OUTFILE "$keys\n$seq_hash{$keys}\n";
	# print alignment with unique IDs 
}
close(OUTFILE);
