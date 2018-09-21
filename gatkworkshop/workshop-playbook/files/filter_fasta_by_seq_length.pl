#!/usr/bin/perl
use strict;
use Data::Dumper;
use Getopt::Std;

eval{
    _main();
};

if($@){
    print $@;
}


sub _main{
    our %opts;
    getopts("i:o:a:b:l:",\%opts);
    my $if = $opts{'i'};
    my $of = $opts{'o'};
    my $min=$opts{'a'}?$opts{'a'}:0;
    my $max = $opts{'b'}?$opts{'b'}:0;
    my $lf = $opts{'l'}?$opts{'l'}:0;

    if(!$if||!$of){
        _usage();
    }
    
    my $lfh;
    if($lf){
        open($lfh,">",$lf) or die "Failed to open lsit file for writing";
    }

    open(my $ofh,">",$of) or die "Failed to open file output file for writing";
    open(my $ifh,"<",$if) or die "Failed to open input file for reading";
    my $seq = "";
    my $name = "";
    while(my $line=<$ifh>){
        if($line=~/^>.*\n$/){
            if($seq){
                if(_check($seq,$min,$max)){
                    print $ofh "$name"."$seq\n\n";
                }
                else{
                    if($lf){
                        print $lfh "$name"."$seq\n\n";
                    }
                }
            }
            $name = $line;
            $seq="";
        }
        else{
            $seq.=$line;
        }
    }
    if(_check($seq,$min,$max)){
        print $ofh "$name"."$seq\n\n";
    }
    else{
        if($lf){
            print $lfh "$name"."$seq\n\n";
        }
    }
    close($ifh);
    close($ofh);
    if($lf){
        close($lfh);
    }
}


sub _check{
    my ($seq,$min,$max) = @_;
    $seq=~s/[\s\t\n\r]//g;
    if($min){
        if(length($seq)<$min){
            return 0;
        }

    }
    if($max){
        if(length($seq)>=$max){
            return 0;
        }
    }
    return 1;
}


sub _usage{
    print STDOUT "\n\nScript filters fasta file by sequence length\n";
    print STDOUT "Parameter:\n";
    print STDOUT "i : input fasta file\n";
    print STDOUT "o : output fasta file\n";
    print STDOUT "a : (optional) minimum length of sequence\n";
    print STDOUT "b : (optional) maximum length of sequence\n";
    print STDOUT "l : (optional) output file of sequences that did not meet criteria\n";
    print STDOUT "\n\n";
    exit;
}



