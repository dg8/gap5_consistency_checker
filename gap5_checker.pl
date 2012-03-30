#!/usr/bin/env perl

=head1 NAME

gap5_checker.pl

=head1 SYNOPSIS

gap5_checker.pl DBNAME.VERS

=head1 DESCRIPTION

This script takes in gap5 database and runs gap5_export and tg_index scripts on it. If stats of a new gap5 database are identical to the stats of the original one then the original database is rewritten by the new one.

=head1 CONTACT

wormhelp@sanger.ac.uk

=cut 


BEGIN { unshift(@INC, 
'/nfs/users/nfs_d/dg8/work_experience/gap5_overnight_check/modules') 
} 
use strict;
use warnings;
use Stats;
use SamStats;
use Gap5Stats;
use StatsCompare;
use PrintOut;

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

print "Running 'gap5_export -format sam -out $sam_file $database.$version'\n";
unless (system("gap5_export -format sam -out $sam_file $database.$version") ){

### STATS GATHERING #######
my $sam_file_obj = SamStats-> new(sam => $sam_file);
my $sam_stats = $sam_file_obj-> stats();

my $gap5_original_obj = Gap5Stats-> new(gap5 => $gap5_original);
my $gap5_original_stats = $gap5_original_obj -> stats();


### STATS COMPARISON (#contigs, total lenght, #sequences, #tags)
my $sam_vs_gap5_original_obj = StatsCompare->new(stats1 =>$sam_stats,
						 stats2 =>$gap5_original_stats);
my $sam_vs_gap5_original_comp = $sam_vs_gap5_original_obj -> compare();

my $sam_print_out= PrintOut-> new (comp_output => $sam_vs_gap5_original_comp,
 				  format => 'sam',
				  file1 => $gap5_original,
				  file2 => $sam_file,
				  file1_stats => $gap5_original_stats,
				  file2_stats => $sam_stats,);


if ( $sam_print_out ->message() ){
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

    
    my $gap5_print_out= PrintOut-> new(comp_output => $gap5_original_vs_new_comp,
 				  format => 'gap5',
				  file1 => $gap5_original,
				  file2 => $gap5_new,
				  file1_stats => $gap5_original_stats,
				  file2_stats => $gap5_new_stats,);

    if ( $gap5_print_out-> message() ){
         print "\t cpdb $gap5_new $gap5_original\n";
            
            # copy($gap5_new, $gap5_original);
            # rm $sam_file;
    }
}

}


sub copy{
    my ($copy, $create)=@_;
    system("rm -f $create.g5d $create.g5x");
    if (-f $copy){
	system("cpdb $copy $create");
    }
}
