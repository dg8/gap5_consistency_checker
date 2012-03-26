package PrintOut;

use Moose;

has 'comp_output'  => (is=>'ro', isa=>'Ref', required=>1); #comparison output
has 'format'       => (is=>'ro', isa=>'Str', required=>1); #sam (sam_vs_gap5) or gap5 (gap5_vs_gap5)
has 'file1'        =>( is=>'ro', isa=>'Str');
has 'file2'        =>( is=>'ro', isa=>'Str');
has 'file1_stats'  =>( is=>'ro', isa=>'Ref');
has 'file2_stats'  =>( is=>'ro', isa=>'Ref');


sub message{
    my ($self) = @_;
    my $output = $self->comp_output;
    
    if (@$output){
      	error_message($self);
	return 0;
    }else{	
       	output_message($self);
	return 1;
    }
}


sub error_message{
    my ($self) =@_;
    my $output = $self->comp_output;
    my $format = $self->format;
    my $file1  = $self->file1;
    my $file2  = $self->file2;
    my $file1_stats = $self->file1_stats;
    my $file2_stats = $self->file2_stats;

     if ($format eq 'sam'){
	 print "The scrip stopped after running 'gap5_export'.\nThe stats of the original gap5 and sam file are different.\n";
     }else{
	 print "The script stopped after running 'tg_index'.\nThe stats of the original gap5 and a new one are different.\n";
     }
    print"\t\t $file1\t$file2\n-----------------------------------------\n";
    foreach my $key (@$output){
	printf("%10s%10d%15d", "$key", "$file1_stats->{$key}", "$file2_stats->{$key}"); 
	print "\n-----------------------------------------\n";
    } 
}

sub output_message{
    my ($self)=@_;
    my $format = $self->format;
    
    if ($format eq 'sam'){
	print "The stats of gap5 and sam file are the same.\nContinue to work, running 'tg_index'.\n";
    }else{
	print "The stats of the original gap5 and a new one are the same.\nYou can copy a new version into your original one, using the following command:\n";
    }
}



1;
