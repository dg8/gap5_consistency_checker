#!/usr/bin/env perl

use strict;
use warnings;
BEGIN{
	use Test::Most;
	use_ok('Gap5Stats');
}

my $gap5='../t/test.0';

ok my $test_obj= Gap5Stats -> new (gap5 => $gap5), 'new object created';

my $correct_stats=[12, 38094, 111425, 33];
my $stats= $test_obj-> stats();

is_deeply ($stats, $correct_stats, 'correct gap5-stats');

done_testing;


