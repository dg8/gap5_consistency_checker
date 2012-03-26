package Gap5Stats;

#########################
#uses db_info script, written by jkb, to get 
#basic information from gap5:
#---------------------------
#Number of contigs:   12
#Total contig length: 38094
#Number of sequences: 111425
#Number of tags:       33
##########################

use Moose;
use Stats;

has 'gap5' => (is => 'ro', isa => 'Str', required =>1);
my $db_info='/nfs/users/nfs_d/dg8/work_experience/gap5_overnight_check/db_info';

my %names2keys = ('Number of contigs'   => 'n_contigs',
		  'Total contig length' => 'total_length',
		  'Number of sequences' => 'n_seqs',
		  'Number of tags'      => 'n_tags',
    );


sub stats{
    my ($self)=@_;    
    my $db= $self->gap5;
    my $stats= Stats->new();

    my $output = `$db_info $db`;
    my @lines=split ('\n', $output);

    foreach my $line (@lines){
	if ( $line =~ /(.+)\:\s+(\d+)/i ){
	    my $stats_key = $names2keys{$1};
	    $stats->$stats_key($2);
	}
    }
    return $stats;
};



1;
