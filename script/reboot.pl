#!/usr/bin/perl

$info = `motelist > motelist.log`;
open fd, "<motelist.log" or die "cannot open motelist.log\n";
while (<fd>) {
	chomp;
	my @rs = split;
	if ($rs[0] eq "FTTEZB5T") {
		my $port = $rs[1];
		my $cmd = "./tos-deluge serial\@$port:115200 -b";
		print "$cmd\n";
		system($cmd);
		last;
	}
}
close fd;
