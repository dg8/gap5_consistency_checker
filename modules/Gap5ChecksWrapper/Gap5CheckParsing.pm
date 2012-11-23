package Gap5ChecksWrapper::Gap5CheckParsing;

=head1 NAME

    Gap5ChecksWrapper/Gap5CheckParsing.pm

=head1 DESCRIPTION

    parsing output of gap5-check 

=head1 CONTACT

wormhelp@sanger.ac.uk

=cut

use Moose;

has 'check_string' => (is => 'ro', isa => 'Str', required =>1);

sub parse{
    my ($self) = @_;
    
    my $check_string = $self->check_string;
    my @check_lines = split (/\n/, $check_string);
    my $previous_line;

    foreach my $line (@check_lines){


    }
}
