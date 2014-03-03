#!/usr/bin/perl

sub excmd() {
	my ($cmd) = @_;
	print "$cmd\n";
	$info = `$cmd`;
}
$no=$ARGV[0];
&excmd("python makeImage.py $no");
sleep(5);
&excmd("perl burnDeluge.pl");
sleep(30);
&excmd("tos-deluge serial@/dev/ttyUSB3:115200 -e 1");
sleep(10);
&excmd("tos-deluge serial@/dev/ttyUSB3:115200 -i 1 tos_image.xml");
sleep(10);
&excmd("tos-deluge serial@/dev/ttyUSB3:115200 -d 1");
exit;
