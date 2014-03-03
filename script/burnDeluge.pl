#!/usr/bin/perl
use threads;
#use threads::shared;

$baseid = $ARGV[0];
$usbfile=$ARGV[1];
my @threads;
my $Tcount=0;
if(!$baseid){
	$baseid = 0;
}
if(!$usbfile){
	$usbfile=usbzju_30
}
$ihex = "main.ihex";
$tosboot = "tosboot.ihex";
$info = `motelist -usb > motelist.txt`;
$path = "build/telosb/";

$dir     = "../GoldenImage/$path";
$basedir = "../BaseStation/$path";
$snfdir  = "../sniffer/";

system("$info");
@usbmaps = ();
open fd, "<$usbfile" or die "cannot open map file\n";
while(<fd>){
	chomp;
	@ret = split;
	
	if($ret[4] =~/ttyUSB/){
		$id = $ret[0];
		$usbport = $ret[3];
		$usbmaps[$id] = $usbport;
	}
}
close fd;

sub findid(){
	my ($usbport) = @_;
	for(my $i = 0; $i<23; $i++){
		if ($usbmaps[$i] eq $usbport) {
			return $i;
		}
	}
	return 0xffff;
}

sub ext(){
my ($cmd)=@_;
system("$cmd");
}

$id =100;
open list, "<motelist.txt" or die "cannot open motelist.txt.\n";
for( $ii=23+$baseid; $ii>=$baseid; $ii--){
	seek(list, 0, SEEK_SET);
	while(<list>) {
		chomp;
		@ret = split;
		if($ret[4] =~/ttyUSB/){
			$port = $ret[4];
			$usbport = $ret[3];
			$id = $ii;
			if( $usbport eq $usbmaps[$id-$baseid]){
            	if ($id==$baseid) {
					$cmd = "tos-set-symbols --objcopy msp430-objcopy --objdump msp430-objdump --target ihex $basedir$ihex $basedir$ihex-$id.out TOS_NODE_ID=$id ActiveMessageAddressC__addr=$id";
                } else {
					$cmd = "tos-set-symbols --objcopy msp430-objcopy --objdump msp430-objdump --target ihex $dir$ihex $dir$ihex-$id.out TOS_NODE_ID=$id ActiveMessageAddressC__addr=$id";
                }
				#$cmd = "tos-bsl-symbols --objcopy msp430-objcopy --objdump msp430-objdump --target ihex $path$ihex $path$ihex $path$ihex-$id.out TOS_NODE_ID=$id ActiveMessageAddressC__addr=$id";
				print "$cmd\n";
				system("$cmd");

				if($id==$baseid) {
					sleep(10);
					$cmd = "tos-bsl --telosb -c $port -r -e -I -p $basedir$ihex-$id.out";
				}
				else {
					$cmd = "tos-bsl --telosb -c $port -r -e -I -p $dir$ihex-$id.out";
				}
				print "$cmd\n";
				#system("$cmd");
				$threads[$Tcount++]=threads->new(\&ext,$cmd);
				print "complete $ii\n";
				last;
			}  #if
		} #if
	}  #while
}    #for

foreach my $thread (@threads){
 $thread->join();
}

close list;

