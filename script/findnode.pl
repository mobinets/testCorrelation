#!/usr/bin/perl

$id = $ARGV[0];
$usbfile = "usbzju_30";

#print "id=$id\n";

open fd, "<$usbfile" or die "cannot open file";

while (<fd>) {
  chomp;
  @rs = split;
  #$rs[0] is the node id $rs[3] is the usb port
  if ($rs[4] =~ /ttyUSB/ && $rs[0] == $id) {
    $usbport = $rs[3];
    last;
  }
}

close fd;

$cmd = "motelist -usb | grep $usbport";
#print "$cmd\n";

$info = `$cmd`;
print "$info";

