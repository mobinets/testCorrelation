#!/usr/bin/perl

$size = $ARGV[0];

if (!$size) {
	$size = 1024;
}

$info = `python makeImage.py $size`; # outputs tos_image.xml

$info = `sed 's/=xxxxx/=$size/g' tos-build-deluge-image-template > tos-build-deluge-image`;
print "$size\n";

#$info = `motelist > motelist.log`;
#open fd, "<motelist.log" or die "cannot open motelist.log\n";
open fd, "<usbzju_30" or die "cannot open usb_30";
while (<fd>) {
	chomp;
	my @rs = split;
	if ($rs[0] eq "0") {
		my $path = $rs[3];
		print $path;
		my $port;
		
		open motelist,"<motelist.txt" or die "cannot open motelist.txt in stop.pl\n";

                while(<motelist>){
                        chomp;
                        my @res = split;
                        if($res[3] eq $path){
                                $port = $res[4];
                                print "port:$port\n";
                        }
                }

		my $cmd = "./tos-deluge serial\@$port:115200 -i 1 tos_image.xml";
		print "$cmd\n";
		system($cmd);
		last;
	}
}
close fd;
close motelist;

