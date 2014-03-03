#!/usr/bin/perl

#$info = `motelist > motelist.log`;
#open fd, "<motelist.log" or die "cannot open motelist.log\n";
open fd, "<usbzju_30" or die "cannot open usb_30 in stop.pl\n";
while (<fd>) {
	chomp;
	my @rs = split;
	if ($rs[0] eq "0") {
		my $hid = $rs[3];
		#my $port = $rs[3];
		my $port;
		#print "path:$path\n";

		open motelist,"<motelist.txt" or die "cannot open motelist.txt in stop.pl\n";
	
		while(<motelist>){
			chomp;
			my @res = split;
			if($res[3] eq $hid){
				$port = $res[4]; 
				#print "port:$port\n";
			}
		}
		my $cmd = "./tos-deluge serial\@$port:115200 -s";
		print "$cmd\n";
		system($cmd);
		last;
	}
}
close fd;
close motelist;
