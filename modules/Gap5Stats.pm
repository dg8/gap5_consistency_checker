package Gap5Stats;

#########################
#uses db_info script, written by jkb, to get 
#basic information from gap5:
#---------------------------
#Number of contigs:   12
#Total contig length: 38094
#Number of sequences: 111425
#Numer of tags:       33
##########################

use Moose;

has 'gap5' => (is => 'ro', isa => 'Str', required =>1);
my $db_info='/nfs/users/nfs_d/dg8/work_experience/gap5_overnight_check/db_info';

sub stats{
    my ($self)=@_;    
    my $db= $self->gap5;
    my @stats;
    my $i=0;
    my $output = `$db_info $db`;
    #print "$output---------------\n";
    my @lines=split ('\n', $output);
    foreach my $line (@lines){
	if ($line =~ /(\d+)/){
	    $stats[$i++]= $1;
	}
#	    $i++;
    }
    return \@stats;
};



1;
