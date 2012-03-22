package SamStats;

######################
#gets basic statistics from sam file
#---------------------------
#Number of contigs:   12
#Total contig length: 38094
#Number of sequences: 111425
#Number of tags:       33
#############################

use Moose;
use Text::CSV;

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
    my @stats;
    
    #first three numbers are found from header (#contigs, Total lenght)
    open (my $sam_header, "samtools view -HS $sam |");
    while (my $line= $csv->getline($sam_header)){
	if ($line->[0] =~ /SQ/){
	    $stats[0]++;
	    for (my $i=0; $i<@$line; $i++){
		if ($line->[$i] =~ /LN\:(\d+)/){
		    $stats[1]+=$1;
		}
	    }
	}
    }
    close $sam_header;

    #finds #seq and #tags from sequence information
    open (my $sam_reads, "samtools view -S $sam |");
    while (my $line= $csv->getline($sam_reads)){
	$stats[2]++;
	if ($line->[0] =~ /^\*/){
	    $stats[3]++;
	    $stats[2]--;
	}
	if (@$line>11){
	    for (my $i=11; $i<@$line; $i++){
		if ($line ->[$i] =~ /^PT\:Z/ ){
		    if ($line ->[$i]=~ /\|\d+\;/){
			my @count= split (/\|/, $line->[$i]);
			$stats[3]+= scalar @count;
		    }else {
			$stats[3]++;
		    }   
		}
	    }
	}
    }
    close $sam_reads;
    
    return \@stats;
}


1;
