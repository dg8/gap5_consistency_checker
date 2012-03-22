#!/usr/bin/env perl

#wrapper script for gap5_export and tg_index
#testing db is fSY21A24.D -> t/test.0
#

BEGIN { unshift(@INC, '/nfs/users/nfs_d/dg8/work_experience/gap5_overnight_check/modules') } 
use strict;
use warnings;
use Getopt::Long;
use SamStats;
use Gap5Stats;
use StatsCompare;

my ($database,$version);

GetOptions ('db|database=s' => \$database,
	    'v|version=s'   => \$version,
    );

if (!$database or not defined ($version)){
    die "usage: overnight_check.pl -db <database> -v <version>\n";
}

my $pwd =`pwd`;
chomp $pwd;
my $tmp_folder="tmp";
mkdir $tmp_folder;# or die "Can't create directory '$temp_folder'";
my $sam_file = "$tmp_folder/$database\.$version\.sam";
my $gap5_original ="$database\.$version";
my $gap5_new = "$tmp_folder/$database\.X";
my $gap5_backup = "$tmp_folder/$database\.Z";

#system("gap5_export -format sam -out $sam_file $database.$version && tg_index -o $gap5_new -s $sam_file");

system("gap5_export -format sam -out $sam_file $database.$version");

### STATS GATHERING #######
my $sam_file_obj = SamStats-> new(sam => $sam_file);
my $sam_stats = $sam_file_obj-> stats();

my $gap5_original_obj = Gap5Stats-> new(gap5 => $gap5_original);
my $gap5_original_stats = $gap5_original_obj -> stats();



## STATS COMPARISON (#contigs, total lenght, #sequences, #tags)
my @stats_names =('Number of contigs', 'Total contig length', 'Number of sequences', 'Number of tags');
my $sam_vs_gap5_original_obj = StatsCompare->new(stats1 =>$sam_stats,
						 stats2 =>$gap5_original_stats);
my $sam_vs_gap5_original_comp = $sam_vs_gap5_original_obj -> compare();

if ($sam_vs_gap5_original_comp){
    print "\ngap5_export didn't work properly, the stats of the original gap5 '$gap5_original' and a sam file '$sam_file' are different.\nFound discrepancies:\n";
    print"\t\t $gap5_original\t $sam_file\n";
    foreach my $i (@$sam_vs_gap5_original_comp){
	printf("%10s%10d%10d", "$stats_names[$i]",   "$gap5_original_stats->[$i]", "$sam_stats->[$i]"); 
	print "\n";
    }

}else{
#### SAM and GAP5 STATS are OK, create a new gap5 database and compare the stats########
    system("tg_index -o $gap5_new -s $sam_file");

    my $gap5_new_obj = Gap5Stats-> new(gap5 => $gap5_new);
    my $gap5_new_stats = $gap5_new_obj-> stats();

    my $gap5_original_vs_new_obj = StatsCompare->new(stats1 => $gap5_original_stats,
						     stats2 => $gap5_new_stats);
    my $gap5_original_vs_new_comp = $gap5_original_vs_new_obj -> compare();

    if (!$gap5_original_vs_new_comp){
	system("rm -f $gap5_original.\*");
	system("rm -f $gap5_backup.\*");
	system("cpdb $gap5_new $gap5_backup");
	system("cpdb $gap5_new $gap5_original");
    }else{
	###### NEW GAP5 IS DIFFERENT #############
	print "\ntg_index didn't work properly, the stats of the original gap5 '$gap5_original' and a new gap5 '$gap5_new' are different.\nFound discrepancies:\n";
	print"\t\t $gap5_original\t $gap5_new\n";
	foreach my $i (@$gap5_original_vs_new_comp){
	    printf("%10s%10d%10d", $stats_names[$i],   $gap5_original_stats->[$i], $gap5_new_stats->[$i]); 
	    print "\n";
	}
    }
}


