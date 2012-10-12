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
use Data::Dumper;

unless (@ARGV){
   die "Usage: $0 DBNAME.VERS\n" ;
}

my $stdout_of_program =  "> /dev/null 2>&1";

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
my $errors_output_file = "$tmp_folder/$database\.X.errors";

print "Running 'gap5_export -test -format sam -out $sam_file $database.$version'\n";
unless (system("gap5_export -test -format sam -out $sam_file $database.$version $stdout_of_program") ){

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


### SAM and GAP5 STATS are OK
### creating a new gap5 database and comparing the stats
copy($gap5_new, $gap5_backup);
system("rm -f $gap5_new.g5d $gap5_new.g5x");

print "Continue to work, running 'tg_index'\n";
system("tg_index -o $gap5_new -s $sam_file $stdout_of_program") and 
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

print gap_check_command($gap5_new, $errors_output_file);

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

sub gap_check_command{
    my ($db, $output_file) = @_;

    my $gap5_check_output = `gap5_check $db`;


    my @check_lines = split (/\n/, $gap5_check_output);
    
    my $total_errors_line = pop @check_lines;
    my $total_errors;
    if ($total_errors_line =~ /(\d+)\s\*\*\*/){
	$total_errors = $1;
    }
    
    my $current_contig = '';
    my %errors_by_contigs;
    foreach my $line (@check_lines){
	if (!$line){next};
	if ($line =~ /^--Checking contig (\#\d+)/){
	    $current_contig= $1;
	}
	if ( $line !~ /^--/  and $current_contig){
	    $errors_by_contigs{$current_contig} .= "$line\n";
	}
    }
    print Dumper %errors_by_contigs;

    if ($total_errors and %errors_by_contigs ){
	open FH, ">$output_file";
	print FH $total_errors_line."\n";
	foreach my $contig (keys %errors_by_contigs){
	    print FH "--Checking contig $contig\n";
	    print FH $errors_by_contigs{$contig};
	}
	close FH;
	
	return "There ". ($total_errors==1? 'is':'are') ." $total_errors error". ($total_errors==1? '':'s') ." found.\nPlease check $output_file for the disctription of the errors.\n";
    }elsif ( $total_errors==1 or $total_errors==0 ){
	
	return  "No errors were found after running gap5_check $db.\n";
    }
}
