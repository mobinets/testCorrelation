#!/usr/bin/perl

sub excmd() {
	my ($cmd) = @_;
	print "$cmd\n";
	$info = `$cmd`;
}

open cc, "<case.list" or die "cannot open cases.lst\n";
open out, ">dissemination.log" or die "cannot open dissemination.log\n";
print out "\# time results for dissemination\n";
while (<cc>) {
	chomp;
	@rs=split;
	$no=$rs[0];
	&excmd("python makeImage.py $no");
	sleep(10);
	&excmd("perl burnDeluge.pl");
	sleep(30);
	&excmd("tos-deluge serial@/dev/ttyUSB3:115200 -i 1 tos_image.xml");
	sleep(10);
	&excmd("tos-deluge serial@/dev/ttyUSB3:115200 -d 1");
	sleep(250);
}
close cc;
close out;
exit;
