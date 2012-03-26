#!/usr/bin/env perl

use strict;
use warnings;

BEGIN{ 
    unshift(@INC, '/nfs/users/nfs_d/dg8/work_experience/gap5_overnight_check/modules');
	use Test::Most;
	use_ok('PrintOut');
}


my $error_output=['n_contigs','total_length'];
my $positive_output=[];
my $sam_format= 'sam';
my $gap5_format= 'gap5';

my $gap5_1= 'test.0';
my $gap5_2= 'test.X';
my $sam_file= 'test.sam';


my $gap5_1_stats  ={'n_contigs'    => 10, 
		    'total_length' => 3000, 
		    'n_seqs'       => 45000, 
		    'n_tags'       => 20};
my $gap5_2_stats  ={'n_contigs'    => 5, 
		    'total_length' => 3001, 
		    'n_seqs'       => 45000, 
		    'n_tags'       => 20};
my $sam_file_stats={'n_contigs'    => 10, 
		    'total_length' => 3000, 
		    'n_seqs'       => 45000, 
		    'n_tags'       => 20};


ok my $gap5_sam_pos_obj = PrintOut ->new(comp_output => $positive_output,
				   format => $sam_format), 'new obj created';

ok my $gap5_sam_err_obj = PrintOut ->new(comp_output => $error_output,
				  format => $sam_format,
				  file1 => $gap5_2,
				  file2 => $sam_file,
				  file1_stats => $gap5_2_stats,
				  file2_stats => $sam_file_stats
), 'new obj created';

ok my $gap5s_pos_obj = PrintOut ->new(comp_output => $positive_output,
				  format => $gap5_format), 'new obj created';

ok my $gap5s_err_obj = PrintOut ->new(comp_output => $error_output,
				  format => $gap5_format,
				  file1 => $gap5_1,
				  file2 => $gap5_2,
				  file1_stats => $gap5_1_stats,
				  file2_stats => $gap5_2_stats
), 'new obj created';
;
is ( $gap5_sam_pos_obj->message(), 1, 'positive gap5_vs_sam');
is ( $gap5_sam_err_obj->message(), 0, 'negative gap5_vs_sam');
is ( $gap5s_pos_obj->message(), 1, 'positive gap5_vs_gap5');
is ( $gap5s_err_obj->message(), 0, 'negative gap5_vs_gap5');



done_testing;
