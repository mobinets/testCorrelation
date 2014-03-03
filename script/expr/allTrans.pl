#!/usr/bin/env perl

# ********** usage ********************
# ** perl allTrans.pl *************
# ** if no log-dir, id start from 1 ...**
# ** the separator is ";"

$num = @ARGV;
my $start=$ARGV[0];
my $logDir=$ARGV[1];
my @nodes;

#$flag="all";
#print STDOUT $flag."\n";

opendir DIR, "." or die "Couldn't open the directory!";
open TRANS, ">./allTrans.txt" or die "Couldn't open the file, $!";

while($file = readdir DIR) {
	if($file =~ /trans/) { #only care about the node*.log file
		open FD, "<./$file" or die "Couldn't open $file !";
		getInfo(*FD,$file); #transfer the FILEHANDLE parameter
		#print STDOUT $file."\n";
		close FD;
	}
}	
close TRANS;
close TIMES;
close DIR;

sub getInfo {
	my $tx = 0;
	my $fh = $_[0] ; # get the first parameter，is equal as $th=shift;
	my $f = $_[1]; # get the file name trans-ctx.log
	my @tmp = split("ct",$f);
	my $name = "ct".$tmp[1];
	
	# read the file by line
	while ($line = <$fh>) {
		chomp;
        @ret = split(":",$line);
		$tx = $tx+ $ret[2]+$ret[3]+$ret[4];
	}
	print TRANS $name.":".$tx."\n";
}


