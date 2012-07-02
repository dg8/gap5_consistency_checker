#!/usr/bin/env perl

=head1 NAME

gap5_checker.pl

=head1 SYNOPSIS

gap5_checker.pl DBNAME.VERS

=head1 DESCRIPTION

This script takes in gap5 database and runs gap5_export and tg_index scripts on it. If stats of a new gap5 database(tmp/DBNAME.X) are identical to the stats of the original one then the original database is rewritten by the new one.

=head1 CONTACT

wormhelp@sanger.ac.uk

=cut 


use strict;
use warnings;
use Stats;
use SamStats;
use Gap5Stats;
use StatsCompare;

unless (@ARGV){
   die "Usage: $0 DBNAME.VERS\n" ;
}

my @input =split (/\./, shift @ARGV);
my $version = pop @input;
my $database = join ('.',@input);
print "The script is going to work on database '$database' and verison '$version'.\n";

my $tmp_folder='tmp';
mkdir $tmp_folder unless -d $tmp_folder;
my $sam_file = "$tmp_folder/$database\.$version\.sam";
my $gap5_original ="$database\.$version";
my $gap5_new = "$tmp_folder/$database\.X";
#my $gap5_new = "$tmp_folder/$database\.$output_version";
my $gap5_backup = "$tmp_folder/$database\.Z";

print "Running 'gap5_export -test -format sam -out $sam_file $database.$version'\n";
unless (system("gap5_export -test -format sam -out $sam_file $database.$version") ){

### STATS GATHERING #######
my $sam_file_obj = SamStats-> new(file_name => $sam_file);
my $sam_stats = $sam_file_obj-> stats();

my $gap5_original_obj = Gap5Stats-> new(gap5 => $gap5_original);
my $gap5_original_stats = $gap5_original_obj -> stats();


### STATS COMPARISON (#contigs, total lenght, #sequences, #tags)
my $sam_vs_gap5_original_obj = StatsCompare->new(stats2 =>$sam_stats,
						 stats1 =>$gap5_original_stats);
my $sam_vs_gap5_original_comp = $sam_vs_gap5_original_obj -> compare();

if ($sam_vs_gap5_original_comp){
   # print "The script stopped after running 'gap5_export'.\n";
    print "The stats of the original gap5 and sam file are different.\n";
    print"\t$gap5_original\t\t$sam_file\n-----------------------------------------\n";
    print $sam_vs_gap5_original_comp;
#    die "Please contact wormhelp\@sanger.ac.uk or jkb\@sanger.ac.uk\n";
}else{
    print "The stats of gap5 and sam file are the same.\n"
}
print "Continue to work, running 'tg_index'.\n";


### SAM and GAP5 STATS are OK
### creating a new gap5 database and comparing the stats
copy($gap5_new, $gap5_backup);
system("rm -f $gap5_new.g5d $gap5_new.g5x");
system("tg_index -o $gap5_new -s $sam_file") and 
    die "Could not run 'tg_index' on $sam_file.";

my $gap5_new_obj = Gap5Stats-> new(gap5 => $gap5_new);
my $gap5_new_stats = $gap5_new_obj-> stats();

my $gap5_original_vs_new_obj = StatsCompare->new(
                                stats1 => $gap5_original_stats,
				stats2 => $gap5_new_stats);
my $gap5_original_vs_new_comp = $gap5_original_vs_new_obj -> compare();

if ($gap5_original_vs_new_comp){
    print "The script stopped after running 'tg_index'.\nThe stats of the original gap5 and a new one are different.\n";
    print"\t\t$gap5_original\t$gap5_new\n-----------------------------------------\n";
    print $gap5_original_vs_new_comp;
    print "If you are happy with a given output\nyou can copy the new version into your original database,\nusing the following command:\n";
  print "\n cpdb $gap5_new $gap5_original\n\n"; 

#    die "Please contact wormhelp\@sanger.ac.uk or jkb\@sanger.ac.uk\n";
}else{
  print "The stats of the original gap5 and a new one are the same.\nYou can copy a new version into your original one, using the following command:\n";
  print "\t cpdb $gap5_new $gap5_original\n"; 
  # copy($gap5_new, $gap5_original);
  # rm $sam_file;
}   
}



sub copy{
    my ($copy, $create)=@_;
    if (-f $create.'.g5d'){
    system("rm -f $create.g5d $create.g5x");
    }
    if (-f $copy.'.g5d'){
	system("cpdb $copy $create");
    }
}
