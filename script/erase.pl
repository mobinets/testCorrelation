#!/usr/bin/perl

$info = `motelist > motelist.log`;
open fd, "<motelist.log" or die "cannot open motelist.log\n";
while (<fd>) {
	chomp;
	my @rs = split;
	#if ($rs[0] eq "M4AP1122") {
		my $port = $rs[1];
		my $cmd = "./tos-deluge serial\@$port:115200 -e 1";
		print "$cmd\n";
		system($cmd);
		
	#}
}
close fd;
