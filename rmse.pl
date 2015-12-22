#!/usr/bin/perl -wall
# A simple implementation of the RMSE calculation used for the Netflix Prize
#use strict;
use warnings;
my $numValues = 0;
my $sumSquaredValues = 0;
my $data_dir = "/home/simon/np/good/dist";

my $i;
opendir(DIR, $data_dir) || die "can't go to $data_dir: $!\n";
foreach $dir2 (sort readdir(DIR))
{
	if (($dir2 ne ".") and ($dir2 ne "..")) {

		opendir(DIR2, "$data_dir/$dir2")|| die "can't go to $data_dir/$dir2: $!\n";
		foreach $file (readdir(DIR2))
		{
			if (($file ne ".") and ($file ne "..")) {
				open(DATA, "< $data_dir/$dir2/$file") || die "can't read: $!\n";	
				while (<DATA>) {
					($i,$rating,$prediction,$i,$i,$i,$i,$i) = split(/\,/);
					my $delta = $rating - $prediction;
					$numValues++;
					$sumSquaredValues += $delta*$delta;
					#print "$delta = $rating - $prediction\n";
					#print "$data_dir/$dir2/$file\n";
					printf "%d pairs RMSE: %.5f\n", $numValues, sqrt($sumSquaredValues/$numValues);
				}
			}
		}
	}
}

