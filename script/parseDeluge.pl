#!/usr/bin/perl

while (<STDIN>) {
  chomp;
  my @rs = split;
  my $time = $rs[0];
  my $type = hex("$rs[20]"); # amtype
  if ($type == 0x50) { # ADV
  	my $sourceAddr = hex("$rs[21]$rs[22]");
  	# version: 23
  	# type   : 24
  	# objid  : 25 26 27 28
  	# numPgs : 29
  	# crc    : 30 31
  	# numPgsComplete: 32
  	# reserved: 33
  	# reserved: 34
  	my $numPgs = hex("$rs[29]");
  	my $numPgsComplete = hex("$rs[32]");
  	print "$time ADV from $sourceAddr: $numPgsComplete/$numPgs\n";
  } elsif ($type == 0x51) { # REQ
  	my $dest = hex("$rs[21]$rs[22]");
  	my $sourceAddr = hex("$rs[23]$rs[24]");
  	# objid: 25 26 27 28
  	my $pgNum = hex("$rs[29]");
  	print "$time REQ from $sourceAddr to $dest: $pgNum\n";
  } elsif ($type == 0x52) { # DATA
  	# objid: 21 22 23 24
  	my $pgNum = hex("$rs[25]");
  	my $pktNum = hex("$rs[26]");
  	print "$time DATA: $pktNum/$pgNum\n";
  } elsif ($type == 0xAB) { #Report
	if (hex("$rs[23]") == 0xE2) {
		my $id = hex("$rs[18]$rs[17]");
		my $sec = hex("$rs[28]$rs[27]$rs[26]$rs[25]")/1024;
		my $txdata = hex("$rs[30]$rs[29]");
		my $rxdata = hex("$rs[32]$rs[31]");
		my $txreq  = hex("$rs[34]$rs[33]");
		my $rxreq  = hex("$rs[36]$rs[35]");
		my $txadv  = hex("$rs[38]$rs[37]");
		my $rxadv  = hex("$rs[40]$rs[39]");
	
		print "$time Report of $id: completed time: $sec; data: $txdata; req: $txreq; adv: $txadv;\n";
	}	
  }
}

exit;


#typedef nx_struct DelugeObjDesc {
#  nx_object_id_t objid;
#  nx_page_num_t  numPgs;         // num pages of complete image
#  nx_uint16_t    crc;            // crc for vNum and numPgs
#  nx_page_num_t  numPgsComplete; // numPgsComplete in image
#  nx_uint8_t     reserved;
#} DelugeObjDesc;
#
#typedef nx_struct DelugeAdvMsg {
#  nx_uint16_t    sourceAddr;
#  nx_uint8_t     version;    // Deluge Version
#  nx_uint8_t     type;
#  DelugeObjDesc  objDesc;
#  nx_uint8_t     reserved;
#} DelugeAdvMsg;
#
#typedef nx_struct DelugeReqMsg {
#  nx_uint16_t    dest;
#  nx_uint16_t    sourceAddr;
#  nx_object_id_t objid;
#  nx_page_num_t  pgNum;
#  nx_uint8_t     requestedPkts[DELUGET2_PKT_BITVEC_SIZE];
#} DelugeReqMsg;
#
#typedef nx_struct DelugeDataMsg {
#  nx_object_id_t objid;
#  nx_page_num_t  pgNum;
#  nx_uint8_t     pktNum;
#  nx_uint8_t     data[DELUGET2_PKT_PAYLOAD_SIZE];
#} DelugeDataMsg;

