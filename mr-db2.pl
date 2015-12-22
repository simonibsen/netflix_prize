#!/usr/bin/perl

use DBI;
use Time::Local;

#
# Set up DB connections
#
	my $dbh = DBI->connect("DBI:mysql:nfp", "nfp", "secret");
	my $load_ratings1 = $dbh->prepare('insert into `mr1-1000` (movie_id, user_id, date, rating) values(?,?,?,?)');
	my $load_ratings2 = $dbh->prepare('insert into `mr1001-2000` (movie_id, user_id, date, rating) values(?,?,?,?)');
	my $load_ratings3 = $dbh->prepare('insert into `mr2001-3000` (movie_id, user_id, date, rating) values(?,?,?,?)');
	my $load_ratings4 = $dbh->prepare('insert into `mr3001-4000` (movie_id, user_id, date, rating) values(?,?,?,?)');
	my $load_ratings5 = $dbh->prepare('insert into `mr4001-5000` (movie_id, user_id, date, rating) values(?,?,?,?)');
	my $load_ratings6 = $dbh->prepare('insert into `mr5001-6000` (movie_id, user_id, date, rating) values(?,?,?,?)');
	my $load_ratings7 = $dbh->prepare('insert into `mr6001-7000` (movie_id, user_id, date, rating) values(?,?,?,?)');
	my $load_ratings8 = $dbh->prepare('insert into `mr7001-8000` (movie_id, user_id, date, rating) values(?,?,?,?)');
	my $load_ratings9 = $dbh->prepare('insert into `mr8001-9000` (movie_id, user_id, date, rating) values(?,?,?,?)');
	my $load_ratings10 = $dbh->prepare('insert into `mr9001-10000` (movie_id, user_id, date, rating) values(?,?,?,?)');
	my $load_ratings11 = $dbh->prepare('insert into `mr10001-11000` (movie_id, user_id, date, rating) values(?,?,?,?)');
	my $load_ratings12 = $dbh->prepare('insert into `mr11001-12000` (movie_id, user_id, date, rating) values(?,?,?,?)');
	my $load_ratings13 = $dbh->prepare('insert into `mr12001-13000` (movie_id, user_id, date, rating) values(?,?,?,?)');
	my $load_ratings14 = $dbh->prepare('insert into `mr13001-14000` (movie_id, user_id, date, rating) values(?,?,?,?)');
	my $load_ratings15 = $dbh->prepare('insert into `mr14001-15000` (movie_id, user_id, date, rating) values(?,?,?,?)');
	my $load_ratings16 = $dbh->prepare('insert into `mr15001-16000` (movie_id, user_id, date, rating) values(?,?,?,?)');
	my $load_ratings17 = $dbh->prepare('insert into `mr16001-17000` (movie_id, user_id, date, rating) values(?,?,?,?)');
	my $load_ratings18 = $dbh->prepare('insert into `mr17001-18000` (movie_id, user_id, date, rating) values(?,?,?,?)');

$data_dir = "/home/simon/home/np/training_set/";

opendir(DIR, $data_dir) || die "can't go to $data_dir: $!\n";
foreach $file (sort readdir(DIR))
{
	open(RATING, "< $data_dir$file") || die "can't read: $!\n";
        while (<RATING>)
        {
                chomp;
		if($i eq undef){ 	
			($movie_id) = (split /:/, $_);	
			$i = 1;
		}
		else{
                	($user_id,$rating,$date) = (split /,/, $_);
			($year,$month,$day) = (split /-/,$date);

			$epoch_date = timelocal(0,0,0,$day,$month-1,$year);
			#print "$time\n";

			if($rating eq ""){
				$rating = "3";
			}
			if($movie_id < 1000) {
				$load_ratings1->execute($movie_id, $user_id, $epoch_date, $rating) || warn "$data_dir$file may have a problem";
			}
			elsif(($movie_id < 2000) and ($movie_id > 1000)){
				$load_ratings2->execute($movie_id, $user_id, $epoch_date, $rating) || warn "$data_dir$file may have a problem"
			}
			elsif(($movie_id < 3000) and ($movie_id > 2000)){
                                $load_ratings3->execute($movie_id, $user_id, $epoch_date, $rating) || warn "$data_dir$file may have a problem"
                        }
			elsif(($movie_id < 4000) and ($movie_id > 3000)){
                                $load_ratings4->execute($movie_id, $user_id, $epoch_date, $rating) || warn "$data_dir$file may have a problem"
                        }
                        elsif(($movie_id < 5000) and ($movie_id > 4000)){
                                $load_ratings5->execute($movie_id, $user_id, $epoch_date, $rating) || warn "$data_dir$file may have a problem"
                        }
			elsif(($movie_id < 6000) and ($movie_id > 5000)){
                                $load_ratings6->execute($movie_id, $user_id, $epoch_date, $rating) || warn "$data_dir$file may have a problem"
                        }
                        elsif(($movie_id < 7000) and ($movie_id > 6000)){
                                $load_ratings7->execute($movie_id, $user_id, $epoch_date, $rating) || warn "$data_dir$file may have a problem"
                        }
                        elsif(($movie_id < 8000) and ($movie_id > 7000)){
                                $load_ratings8->execute($movie_id, $user_id, $epoch_date, $rating) || warn "$data_dir$file may have a problem"
                        }
                        elsif(($movie_id < 9000) and ($movie_id > 8000)){
                                $load_ratings9->execute($movie_id, $user_id, $epoch_date, $rating) || warn "$data_dir$file may have a problem"
                        }
			elsif(($movie_id < 10000) and ($movie_id > 9000)){
                                $load_ratings10->execute($movie_id, $user_id, $epoch_date, $rating) || warn "$data_dir$file may have a problem"
                        }
                        elsif(($movie_id < 11000) and ($movie_id > 10000)){
                                $load_ratings11->execute($movie_id, $user_id, $epoch_date, $rating) || warn "$data_dir$file may have a problem"
                        }
                        elsif(($movie_id < 12000) and ($movie_id > 11000)){
                                $load_ratings12->execute($movie_id, $user_id, $epoch_date, $rating) || warn "$data_dir$file may have a problem"
                        }
                        elsif(($movie_id < 13000) and ($movie_id > 12000)){
                                $load_ratings13->execute($movie_id, $user_id, $epoch_date, $rating) || warn "$data_dir$file may have a problem"
                        }
                        elsif(($movie_id < 14000) and ($movie_id > 13000)){
                                $load_ratings14->execute($movie_id, $user_id, $epoch_date, $rating) || warn "$data_dir$file may have a problem"
                        }
                        elsif(($movie_id < 15000) and ($movie_id > 14000)){
                                $load_ratings15->execute($movie_id, $user_id, $epoch_date, $rating) || warn "$data_dir$file may have a problem"
                        }
                        elsif(($movie_id < 16000) and ($movie_id > 15000)){
                                $load_ratings16->execute($movie_id, $user_id, $epoch_date, $rating) || warn "$data_dir$file may have a problem"
                        }
                        elsif(($movie_id < 17000) and ($movie_id > 16000)){
                                $load_ratings17->execute($movie_id, $user_id, $epoch_date, $rating) || warn "$data_dir$file may have a problem"
                        }	
			elsif(($movie_id < 18000) and ($movie_id > 17000)){
                                $load_ratings18->execute($movie_id, $user_id, $epoch_date, $rating) || warn "$data_dir$file may have a problem"
                        }
		}
        }
        close(RATING);
	undef($i);
}
