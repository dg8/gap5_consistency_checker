#!/usr/bin/env perl

use strict;
use warnings;
BEGIN{
	use Test::Most;
	use_ok('SamStats');
}

my $sam_file='../t/test.0.sam';
#    '/nfs/repository/working_area/fSY21A24/tmp/fSY21A24.D.sam';

ok my $test_obj= SamStats -> new (sam => $sam_file), 'new object created';

my $correct_stats=[12, 37894, 111425, 27];
my $stats= $test_obj-> stats();

is_deeply ($stats, $correct_stats, 'correct gap5-stats');

done_testing;


