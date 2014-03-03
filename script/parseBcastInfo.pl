open fd, "<$ARGV[0]" or die "cannot open file in parseBcastInfo\n";

## the index is node id
my @mytime = ();
my @mydata = ();
my @myreq  = ();
my @myadv  = ();


while (<fd>) {
  chomp;
  @results = split;
  my $type = hex("$results[20]");
  
  my $id = hex("$results[18]$results[17]");
  my $subtype = hex("$results[23]");
  # reserved
  my $t1 = hex("$results[28]$results[27]$results[26]$results[25]");
  my $txdata = hex("$results[30]$results[29]");
  my $rxdata = hex("$results[32]$results[31]");
  my $txreq  = hex("$results[34]$results[33]");
  my $rxreq  = hex("$results[36]$results[35]");
  my $txadv  = hex("$results[38]$results[37]");
  my $rxadv  = hex("$results[40]$results[39]");
  
  if ($type == 0xAB) {
  	if ($subtype == 0xE2) {
  		my $sec = $t1/1024; # ms?
  		#print "$id $sec($txdata,$txreq,$txadv)\n";
  		$mytime[$id] = $sec;
  		$mydata[$id] = $txdata;
  		$myreq[$id]  = $txreq;
  		$myadv[$id]  = $txadv;
  	}
  	else {
  		#print "error msg\n";
  	}
  }
}

close fd;

$totaltime=0;
$totaldata=0;
$totalreq=0;
$totaladv=0;

for ($i=0; $i<=300; $i++) {
  if ($i==0 || $mytime[$i]>1) {
  	print "$i $mytime[$i]($mydata[$i],$myreq[$i],$myadv[$i])\n";
  	if ($mytime[$i]>$totaltime and $i != 0) {
		$totaltime=$mytime[$i]; 
	}
  	$totaldata += $mydata[$i];
  	$totalreq  += $myreq[$i];
  	$totaladv  += $myadv[$i];
  }	
}

#$totaltime = $totaltime - $mytime[0];
print "Total $totaltime($totaldata,$totalreq,$totaladv)\n";
