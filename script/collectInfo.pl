#!/usr/bin/perl
use threads;
#usage : perl collectInfo.pl FILE STARTPLACE REPEAT
#FILE : the name of input file
#STARTPLACE : the place you want it to disseminate from 
#REPEAT : repeat time

sub ext(){
my ($cmd)=@_;
system("$cmd");
}
my $thread;
my $file = $ARGV[0];
my $start = $ARGV[1];
my $repeat = $ARGV[2];

if(!$file){
	$file = "deluge.log";
}

if(!$start){
	$start = 0;
}

if(!$repeat){
	$repeat = 1;
}

my $done = 0;

while($done < $repeat ){
	open fd, "<$file" or die " cannot open file in collectInfo.\n";

	$cur = 0;
	while(<fd>){
		chomp;
		@res = split;
	
		if($cur<$start and $res[1]!=0){
			$cur += 1;
			print $cur;
		} elsif($res[1] == 0){
		#do nothing	
		} else	{  #start work
			print "start work\n";
			$info = `perl stop.pl`;
			sleep(2);
			
			$info = `./tos-deluge serial@/dev/ttyUSB3:115200 -b`;
			sleep(2);
			
			print "finish stop.pl, go to inject $res[1].\n";
			$info = `perl inject.pl $res[1]`;
			
			print "please listen to serial ports!\n";
			sleep(10);
			
						
			print "finish injec.pl, go to disseminate.pl.\n";
			
			$info = `perl disseminate.pl`;
		}
	
	}

	close fd;
	$done += 1;
}
