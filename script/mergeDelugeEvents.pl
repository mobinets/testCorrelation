#!/usr/bin/perl

my $nums = @ids;
my $time = $ARGV[0];

if(!$time) {
	print "Usage:perl mergeDelugeEvents.pl [time]\n";
	print "  the file for read is generated by cat.sh\n";
	print "  the generated event files in dir events\n";
}
# open the file to read

open FD, "<../result/result.log" or die "cannot open result.log file\n";
for($n=0; $n<8; $n++){
	$cmd="FD$n";
	open $cmd, ">../result/events/event$n" or die "cannot open map file\n";
}
	
for($i=0; $i<8; $i++) {
			
	# find the usbport of the given node id
	while (<FD>) {
		chomp;
		@ret = split;
		
		if($ret[2] < $time){
			$cmd1="FD$ret[1]";
			print $cmd1 "@ret\n";
		}
	}
	
}
close FD;
for($j=0; $j<6; $j++){
	$cmd2="FD$j";
	close $cmd2;
}