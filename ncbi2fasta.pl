#!/usr/bin/perl 
use Bio::DB::GenBank;

# Script modified from https://raunakms.wordpress.com/2011/12/24/download-sequence-from-accession-number-using-perl/

my $input_file = $ARGV[0];
open (INPUT_FILE,'<', $input_file) or die "\nThis script will fetch nucleotide sequences from NCBI GenBank based on their accession numbers.\nPlease provide path to file containing accession numbers (one per line or separated by commas).\nOutput will be directed to STDOUT!\n\n";

while(<INPUT_FILE>)
{
    chomp;

    my $line = $_;
    my @acc_no = split(",", $line);

    my $counter = 0;

    while ($acc_no[$counter])
    {
        $acc_no[$counter] =~ s/\s//g;

        if ($acc_no[$counter] =~ /^$/)
        {
            exit;
        }

        my $db_obj = Bio::DB::GenBank->new;

        my $seq_obj = $db_obj->get_Seq_by_acc($acc_no[$counter]);

        my $sequence1 = $seq_obj->seq;

	my $name1     = $seq_obj->desc();

        print STDOUT ">"."$name1","\n";

        print STDOUT $sequence1,"\n";

        $counter++;
    }
}

close INPUT_FILE;

exit;
