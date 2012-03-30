package SamStats;

#####################################
#gets basic statistics from sam file,
#saves into Stats object
#---------------------------
#Number of contigs:   12
#Total contig length: 38094
#Number of sequences: 111425
#Number of tags:       33
#############################

use Moose;
use Text::CSV;
use Stats;

has 'sam'   => (is => 'ro', isa => 'Str', required =>1);
has '_input_fh'  => (is=>'ro', lazy_build=>1);

sub _build__input_fh {
    my ($self)=@_;
    my $csv = Text::CSV-> new ({binary   =>1, 
				sep_char => "\t", 
			})
    or die "Cannot use CSV: ".Text::CSV->error_diag();
    return $csv;
}

sub stats{
    my ($self)=@_;
    my $sam= $self->sam;
    my $csv = $self->_input_fh;
    my $stats= Stats->new();
    
    #finds n_contigs, total_lenght from header
    open (my $sam_header, "samtools view -HS $sam |grep '^\@SQ' |")
	or die "Could not open $sam";
    while (my $line= $csv->getline($sam_header)){
	    $stats->n_contigs($stats->n_contigs+1);#$stats[0]++;
	    foreach my $syl (@$line){ 
		if ($syl =~ /LN\:(\d+)/){
		    $stats->total_length($stats->total_length+$1);
		}
	    }
    }
    close $sam_header;

    #finds n_seqs and n_tags from sequence information
    my $output = `samtools view -S $sam | grep -vc '^\*' `;
    chomp $output;
    $stats->n_seqs($output);

    open (my $sam_reads, "samtools view -S $sam | grep -v 'sam\$' |")
	or die "Could not open $sam";
    while ( my $line= $csv->getline($sam_reads) ){
	if ($line->[0] =~ /^\*/){
	    $stats->n_tags($stats->n_tags+1);
	}
	if (@$line>11){
	    for (my $i=11; $i<@$line; $i++){
		if ($line ->[$i] =~ /^PT\:Z/ ){
			my @count= split (/\|/, $line->[$i]);
			$stats->n_tags($stats->n_tags+scalar @count);	
		}
	    }
	}
    }
    close $sam_reads;
    
    return $stats;
}


1;


