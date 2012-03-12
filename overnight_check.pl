#!/usr/bin/env perl

#wrapper script for gap5_export and tg_index
#testing db is fSY21A24.D

use strict;
use warnings;
use Getopt::Long;
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
mkdir $temp_folder;# or die "Can't create directory '$temp_folder'";# unless (-d "$temp_folder");
my $sam_file = "$temp_folder/$database\.$version\.sam";
#print $sam_file."\n";
my $gap5_name = "$temp_folder/$database\.X";
#print $gap5_name."\n";

system("gap5_export -format sam -out $sam_file $database.$version && tg_index -o $gap5_name -s $sam_file");









