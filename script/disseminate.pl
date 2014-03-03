#!/usr/bin/perl

#$info = `motelist > motelist.log`;
#open fd, "<motelist.log" or die "cannot open motelist.log\n";
open fd,"<usbzju_30" or die "cannnot open usb_50.\n";
while (<fd>) {
	chomp;
	my @rs = split;
	if ($rs[0] eq "0") {
		my $path = $rs[3];
		my $port;

		open motelist,"<motelist.txt" or die "cannot open motelist.txt in stop.pl\n";

                while(<motelist>){
                        chomp;
                        my @res = split;
                        if($res[3] eq $path){
                                $port = $res[4];
                                #print "port:$port\n";
                        }
                }

		my $cmd = "./tos-deluge serial\@$port:115200 -d 1";
		print "$cmd\n";
		system($cmd);
		last;
	}
}
close fd;
close motelist;
