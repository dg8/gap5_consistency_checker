#!/usr/bin/env perl

use strict;
use warnings;
BEGIN{
        use Test::Most;
	use_ok('StatsCompare');
}

my $stats1=[12, 3000, 45000, 10];
my $stats2=[13, 3001, 45000, 10];

ok my $identical_obj= StatsCompare -> new (stats1 => $stats1,
    stats2 => $stats1), 'new \'similar\' object created';
ok my $different_obj= StatsCompare -> new (stats1 => $stats1,
    stats2 => $stats2), 'new \'different\' object created';


my $diff=[0,1];

my $identical_comparison= $identical_obj-> compare();
my $diff_comparison= $different_obj-> compare();

is($identical_comparison, 0, 'identical arrays');
is_deeply ($diff_comparison, $diff, 'different arrays');




done_testing;


