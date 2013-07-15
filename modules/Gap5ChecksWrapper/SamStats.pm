
package Gap5ChecksWrapper::SamStats;

=head1 NAME

Gap5ChecksWrapper/SamStats.pm

=head1 DESCRIPTION

gets basic statistics from sam file,saves into Stats object:
number of contigs, total contig length, number of sequences, number of tags

=head1 CONTACT

wormhelp@sanger.ac.uk

=cut

use Moose;
use Text::CSV;
use Gap5ChecksWrapper::Stats;
use Bio::DB::Sam;


has 'bam_name'   => (is => 'ro', isa => 'Str', required =>1);

sub stats{
    my ($self)=@_;

    my $bam= $self->bam_name;
    my $stats= Gap5ChecksWrapper::Stats->new();
#    my $bam = $sam.'.bam';
#    `samtools view -hb -S $sam > $bam`;
    my $bam_obj = Bio::DB::Sam->new(-bam => $bam);
    my $header = $bam_obj->header;
    my $num_targets = $bam_obj->n_targets;
    print "number of contigs: $num_targets\n";
    my @seq_ids = $bam_obj->seq_ids;
    my $length=0;
    foreach my $seqid (@seq_ids){
	$length +=$bam_obj->length($seqid);
    }
    print "total length: $length\n";



### finds n_contigs, total_lenght from header
    open (my $bam_header, "samtools view -H $bam |grep '^\@SQ' |")
	or die "Could not open $bam";
    while (my $lane= <$bam_header>){
	chomp $lane;
	my $rows= [ split(/\t/, $lane) ];
	    $stats->n_contigs($stats->n_contigs+1);#$stats[0]++;
	    foreach my $syl (@$rows){ 
		if ($syl =~ /LN\:(\d+)/){
		    $stats->total_length($stats->total_length+$1);
		}
	    }
    }
    close $bam_header;
    



#if (0){
### finds n_seqs from sequence information
    my $output = `samtools view $bam | grep -vc '^\*' `;
    chomp $output;
    $stats->n_seqs($output);

### finds n_tags from sequence information
    open (my $bam_reads, "samtools view $bam | grep -v '.sam\$' |")
	or die "Could not open $bam";

     while ( my $lane= <$bam_reads> ){
     chomp $lane;
     my $rows = [ split(/\t/, $lane) ];

 	if ($rows->[0] eq '*') {
 	    $stats->n_tags($stats->n_tags +1);
 	}

	for (my $i=11; $i<@$rows; $i++){
		if ($rows ->[$i] =~ /^PT\:Z/ ){
			my @count= split (/\|/, $rows->[$i]);
			$stats->n_tags($stats->n_tags + @count);	
		}
	}
    }

     close $bam_reads;
#}    
    return $stats;
}


1;


