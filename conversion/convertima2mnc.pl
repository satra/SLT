#!/usr/bin/perl

($srcdir,$targdir) = @ARGV;

$tempdir= sprintf("/tmp/blah_%f",rand());

system("mkdir $tempdir");
printf("%s\n",$tempdir);
system("ima2mnc -wait $srcdir $tempdir");
printf("ima2mnc: done\n");
$res = `ls $tempdir`;
chop $res;
$tempdir1 = "$tempdir/$res";
system("unpackmincdir -src $tempdir1 -targ $targdir -minconly");
printf("unpackmincdir: done\n");
system("rm -rf $tempdir");
