#!/usr/bin/env perl

# ********** usage ********************
# ** perl TransAndTime.pl <startTime> <log-dir>...**
# ** if no log-dir, id start from 1 ...**
# ** the separator is ";"

$num = @ARGV;
my $start=$ARGV[0];
my $logDir=$ARGV[1];
my @nodes;

if($num != 2) {
	print STDOUT "usage: perl TransAndTime.pl <startTime> <log-dir>\n";
	die;
}

#$flag=substr($logDir,length($logDir)-3,3); #get the last two char of dir: g1
$flag="all";
#print STDOUT $flag."\n";

opendir DIR, "$logDir" or die "Couldn't open the directory!";
open TRANS, ">expr/trans-$flag.txt" or die "Couldn't open trans.log, $!";
open TIMES, ">expr/times-$flag.txt" or die "Couldn't open times.log, $!";

while($file = readdir DIR) {
	if($file =~ /node/) { #only care about the node*.log file
		open FD, "<$logDir/$file" or die "Couldn't open $file !";
		getInfo(*FD,$file); #transfer the FILEHANDLE parameter
		close FD;
	}
}	
close TRANS;
close TIMES;
close DIR;

sub getInfo {
	$fh = $_[0] ; # get the first parameter，is equal as $th=shift;
	$f = $_[1]; # get the file name node1.log
	$tmp = index($f,".");
	$id = substr($f,4,$tmp-4);
	$bptx="";
	$bpTime="";
	
	# read the file by line
	while ($line = <$fh>) {
		chomp;
		$str1 = substr($line,0,6); #get the first 6 substr
		$str2 = substr($line,0,19); #get the first 10 substr
		if($str1 eq "#BP#TX") {
			$bptx = $line;
		} elsif ($str1 eq "#BP#TC") {
			$bpTime= $line;
		}
		if($str2 eq "#OTP: finish image!") { # OTP: finish image!curPgNum=21,t=355566
			@ret = split("=",$line);        # $ret[2]=355566
			print TIMES sprintf("%ld, "x4,$id,$start,$ret[2],$ret[2]-$start)."\n";
		}
	}
	print TRANS $bptx;
	print TRANS $bpTime;
}


