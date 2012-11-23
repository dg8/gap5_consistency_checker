package Gap5ChecksWrapper::Stats;

use Moose;

has 'n_contigs'    => (is => 'rw', isa => 'Int', default => 0 );
has 'total_length' => (is => 'rw', isa => 'Int', default => 0 );
has 'n_seqs'       => (is => 'rw', isa => 'Int', default => 0 );
has 'n_tags'       => (is => 'rw', isa => 'Int', default => 0 );

1;
