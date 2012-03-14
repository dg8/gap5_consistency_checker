#!/usr/bin/env perl

#wrapper script for gap5_export and tg_index
#testing db is fSY21A24.D
#/nfs/users/nfs_d/dg8/work_experience/gap5_overnight_check/overnight_check.pl -db fSY21A24 -v D

use strict;
use warnings;
use Getopt::Long;
use Array::Compare;
use Data::Dumper;

my $database; 
my $version=0;

GetOptions ('db|database=s' => \$database,
	    'v|version=s'   => \$version,
    );

if (!$database or !$version){
    die "usage: overnight_check.pl -db 'database' -v 'version'";
}

my $pwd =`pwd`;
chomp $pwd;
my $temp_folder="$pwd/temp";
mkdir $temp_folder;# or die "Can't create directory '$temp_folder'";
my $sam_file = "$temp_folder/$database\.$version\.sam";
my $gap5_name = "$temp_folder/$database\.X";
my $gap5_backup = "$temp_folder/$database\.Z";
my $gap5_db =$database.'.'.$version;


system("gap5_export -format sam -out $sam_file $database.$version && tg_index -o $gap5_name -s $sam_file");


## STATS COMPARISON (#contigs, total lenght, #sequences, #tags)

my @stats_names =('contigs', 'total_length', 'sequences', 'tags');
my $db_info='/nfs/users/nfs_d/dg8/work_experience/gap5_overnight_check/db_info';

my $original_stats = db_stats($gap5_db);
my $output_stats = db_stats($gap5_name);

my $comp= Array::Compare->new;
if ($comp->compare($original_stats,$output_stats)){
    system("rm -f $gap5_backup.\*");
    system("cpdb $gap5_name $gap5_backup");
    system("cpdb $gap5_name $gap5_db");
}else{
    print "there is a problem\n";
    my @full_comp= $comp->full_compare($original_stats,$output_stats);
    foreach my $i (@full_comp){
	print "Found differences within $stats_names[$i].\nNumbers are the following:\n $gap5_db \t $original_stats->[$i]\n $gap5_name\t $output_stats->[$i]\n";
    }
}


sub db_stats{
    my ($db)=@_;    
    my @stats;
    my $i=0;
    my $output = `$db_info $db`;
    #print "$output---------------\n";
    my @lines=split ('\n', $output);
    foreach my $line (@lines){
	if ($line =~ /(\d+)/){
	    $stats[$i++]= $1;
	}
#	    $i++;
    }
    return \@stats;
};


