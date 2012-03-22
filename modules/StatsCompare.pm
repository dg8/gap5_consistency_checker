package StatsCompare;

######################
#compares two given arrays,
#gives 0 if they identical and
#ref of array with positions where differences occur.
#####################

use Moose;
use Array::Compare;

has 'stats1' => (is =>'ro', isa => 'Ref', required => 1);
has 'stats2' => (is =>'ro', isa => 'Ref', required => 1);

my $comp= Array::Compare->new;

sub compare{
    my ($self)=@_;
    my $stats1= $self -> stats1;
    my $stats2= $self -> stats2;
    my $comp= Array::Compare->new;
    
    if ( $comp->compare($stats1,$stats2) ){
	return 0;
    }else{
#	print "there is a problem\n";
	my @full_comp= $comp->full_compare($stats1,$stats2);
	return \@full_comp;
    }
}


