package Gap5ChecksWrapper::Gap5Stats;

=head1 NAME

Gap5ChecksWrapper/Gap5Stats.pm

=head1 DESCRIPTION

uses 'db_info' script, written by jkb, to get basic information from gap5: number of contigs, total contig length, number of sequences, number of tags

=head1 CONTACT

wormhelp@sanger.ac.uk

=cut

use Moose;
use Gap5ChecksWrapper::Stats;

has 'gap5' => (is => 'ro', isa => 'Str', required =>1);

my %names2keys = ('Number of contigs'   => 'n_contigs',
		  'Total contig length' => 'total_length',
		  'Number of sequences' => 'n_seqs',
		  'Number of tags'      => 'n_tags',
    );


sub stats{
    my ($self)=@_;    
    my $db= $self->gap5;
    my $stats= Gap5ChecksWrapper::Stats->new();

    my $output = `db_info $db`; 
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
