#!/usr/bin/env perl

use strict;
use warnings;
BEGIN{
    unshift(@INC, '/nfs/users/nfs_d/dg8/work_experience/gap5_overnight_check/modules');
        use Test::Most;
	use_ok('StatsCompare');
	use_ok('Stats');
}


ok my $stats1_obj=Stats -> new(n_contigs    => 12, 
			       total_length => 3000, 
			       n_seqs       => 45000, 
			       n_tags       => 10), 'Stats1 object created';

ok my $stats2_obj=Stats -> new(n_contigs    => 13, 
			       total_length => 3001, 
			       n_seqs       => 45000, 
			       n_tags       => 10), 'Stats2 object created';


ok my $identical_obj= StatsCompare -> new (stats1 => $stats1_obj,
    stats2 => $stats1_obj), 'new \'similar\' object created';
ok my $different_obj= StatsCompare -> new (stats1 => $stats1_obj,
    stats2 => $stats2_obj), 'new \'different\' object created';


my $diff=['n_contigs','total_length'];

my $identical_comparison= $identical_obj-> compare();
my $diff_comparison= $different_obj-> compare();

is_deeply ($identical_comparison, [], 'identical arrays');
is_deeply ($diff_comparison, $diff, 'different arrays');




done_testing;


