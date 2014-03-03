#! /usr/bin/perl

$base = "./BaseStation";
$image = "./GoldenImage";

# now at script dir, change to the parent dir.
chdir("../");
if(!chdir($image)) {
	print STDOUT "change GoldenImage dir error!\n";
	die;
}
$dir_1 = `pwd`;
#print STDOUT "now at $dir_1\n";
system("make clean");
system("make telosb");

# now at GoldenImage dir, change to the parent dir.
chdir("../");
$dir_1 = `pwd`;
#print STDOUT "now at $dir_1\n";

if(!chdir($base)) {
	print STDOUT "change BaseStation dir error!\n";
	die;
}
$dir_1 = `pwd`;
#print STDOUT "now at $dir_1\n";
system("make clean");
system("make telosb");
