package StatsCompare;

######################
#compares two Stats objects,
#gives 0 if they identical and
#ref of array with positions where differences occur.
#####################

use Moose;
use Stats;

has 'stats1' => (is =>'ro', isa => 'Stats', required => 1);
has 'stats2' => (is =>'ro', isa => 'Stats', required => 1);

my @keys=('n_contigs', 'total_length', 'n_seqs', 'n_tags');


sub compare{
    my ($self)=@_;
    my $stats1= $self -> stats1;
    my $stats2= $self -> stats2;
    my @full_comp=();
    
    foreach my $key (@keys){
	if ( $stats1->{$key} != $stats2->{$key} ){
	    push @full_comp, $key;
	}	
    }
    return \@full_comp;
}


