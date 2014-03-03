#!/usr/bin/perl

# ********** usage ********************
# ** perl printNode.pl <id1> <id2>...**
# ** if no param, id start from 1 ...**

use threads;
$info = `motelist -usb > motelist.txt`;
my @ids=@ARGV;  # get the node id param.
my $nums = @ids;
if(!$nums) {
	@ids=(1..23);
    $nums=23;
}
	
my @threads;
print "nodes:@ids\n";


# open the file to read
open FD, "<usbzju_30" or die "cannot open map file\n";
####
$date = `date +%Y-%M-%d_%H-%m-%S`;
my $dir = "log-$date/";
system("mkdir log");
print $dir;
####

# find the usbport of the given node id
while (<FD>) {
	chomp;
	@ret = split;
	
	for($i=0; $i<$nums; $i++) {
	
		# $ret[0] is the node id and $ret[3] is serial physical address and $ret[4] is the logic usb port
		if ($ret[4] =~ /ttyUSB/ && $ret[0] == $ids[$i]) {
			$port = $ret[4];
            ##$file = "$date" + "node$ids[$i].log";
			$cmd = "java net.tinyos.tools.PrintfClient -comm serial\@$port:telosb > log/node$ids[$i].log";
			print "$cmd\n";
			$threads[$i]=threads->new(\&ext,$cmd);
			last;
		}
	}
}

#system("$cmd");

sub ext(){
	my ($cmd)=@_;
	system("$cmd");
}

foreach my $thread (@threads){
 $thread->join();
}

close fd;

