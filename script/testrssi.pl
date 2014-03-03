#!/usr/bin/perl

use threads;
use threads::shared;

#$file = $ARGV[0];

$MAX_NODE_CNT = 1000;

my @counter : shared;
my @sum     : shared;
my @ver	    : shared;

my $thr0 = threads->create(\&pr);   
my $thr1 = threads->create(\&filein);   

$thr0->join;  
$thr1->join; 

sub filein()
{
#	open fd, "<$file" or die "cannot open file\n";
	open fd, "java ListenTime |" or die "cannot open file\n";
	$test = 0;
	while (<fd>) {
		chomp;
		@pkt = split;
		if (hex("$pkt[20]") == 0x70) {
			#$pkt_type = hex("$pkt[19]");
			$pkt_src = hex("$pkt[18]$pkt[17]");
			$tmp_rssi = hex("$pkt[-5]");
			$tmp_ver = hex("$pkt[28]$pkt[29]");		

			if ($tmp_rssi < 127) {
				$tmp_rssi -= 45; 
			}
			else {
				$tmp_rssi = $tmp_rssi - 256 - 45;
			}

			$ver[$pkt_src] = $tmp_ver;

			$test += 1;
#			system("pause");
		
			if ($pkt_src >= 1 and $pkt_src <= 100) { 
				$sum[$pkt_src] += $tmp_rssi;
				$counter[$pkt_src] += 1;
				print "\r >> $test $pkt_src $counter[$pkt_src] $sum[$pkt_src] $tmp_rssi";	
			}
		}
	}
}
		

sub pr()
{
	lock(@sum);
	lock(@counter);
	lock(@ver);
	while (<STDIN>) {
		@pkt = split;
		if ($pkt[0] == '\n'){
			print "\n>>\n>>";
			$prt = 0;
			for (my $i = 1; $i < $MAX_NODE_CNT; $i++){
				if ($counter[$i] != 0){
					printf "%d(%x, %d,%.2f)  ",$i,$ver[$i],$counter[$i],$sum[$i] * 1.0 /$counter[$i];
					#print "$i($counter[$i],$sum[$i] * 1.0 /$counter[$i])  ";
					$prt ++;
					$prt %= 6;
					if ($prt == 0){
						print "\n  ";
					}
				}
			}
			print "\n\n";
		}
	}
}

