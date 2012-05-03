package StatsCompare;

=head1 NAME

StatsCompare.pm

=head1 DESCRIPTION

compares two Stats objects, gives 0 if they identical or string with differences if stats differ

=head1 CONTACT

wormhelp@sanger.ac.uk

=cut 

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
    
    if (@full_comp){
	my $compare_string;
	foreach my $key (@full_comp){
	    $compare_string .=sprintf("%10s%10d%15d\n-----------------------------------------\n", 
				      "$key", "$stats1->{$key}", "$stats2->{$key}"); 
	} 
	return $compare_string;
    }else{
	return 0;
    }
}


