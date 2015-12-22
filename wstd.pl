#!/usr/bin/perl 

use DBI;
use List::Util 'shuffle';

$result_dir = $ARGV[0];
$start_value = $ARGV[1];
$stop_value = $ARGV[2];


#
# Set up DB connections
#
	my $dbh = DBI->connect("DBI:mysql:nfp:sloth:3306", "nfp", "secret");
	my $get_rating = $dbh->prepare('select rating from movie_rating where `movie_id` = ? and `user_id` = ? limit 1');


open(PROBE, "< /home/simon/np/probe.txt") || die "can't read: $!\n";
while (<PROBE>){
	chomp;
	if(/.*\:$/){ 	
		($movie_id) = (split /:/, $_);	
		$movie_number++;
		$percdone = $numValues/1425333;
		if ($movie_id == $start_value){
			$status = "go";
		}
		if ($movie_id == $stop_value){
                        $status = "stop";
                }
	}
	else{
		if ($status eq "go"){
			$user_id =  $_;
			
			$get_rating->execute("$movie_id", "$user_id");
			@get_rating_response = $get_rating->fetchrow;
			$rating = $get_rating_response[0];

			($prediction,$user_avstddev_ratings,$user_av_ratings, $seer_rating_average, $std_status) = &predict_rating($movie_id, $user_id);
			open(RESULTS,">>/home/simon/np/good/dist/linux/$result_dir/results.txt");
			# MovieID, rating, prediction, std, user average, seer average, whether std was used in prediction
			#print RESULTS "$prediction, $rating\n";
			my $delta = $rating - $prediction;
			$delta = abs($delta);
			print RESULTS "$movie_id,$rating,$prediction,$delta,$user_avstddev_ratings,$user_av_ratings,$std_status\n";
			close(RESULTS);
			$numValues++;
			$sumSquaredValues += $delta*$delta;
		}

	}
}
close(PROBE);

sub predict_rating {
	my $movie =  $_[0];
	my $user = $_[1];
	
	my $get_user_movies = $dbh->prepare('select movie_id,rating from movie_rating where user_id = ?');
	$get_user_movies->execute("$user");	
	
	my @user_movies;
	my @row0;
	my %target_user_ratings;
	my $movie_count;
	my $total_seers;
        my $seer_user_id;
        my %seer_user_ratings;
        my %seer_user_hit_count;
        my $total_seer_rating_delta;

        my $seer_rating_average_calc;
        my $seer_rating;

        my %predictor_value_hash;

        my $count;
	my $first_movie;
	my $seer_movie;
	my $get_seer_moviesq;
	my $secount = 0;


	while ( @row0 = $get_user_movies->fetchrow_array ) {
		# These are all the movies that user has seen
		push @user_movies, $row0[0]; 

		# This is target user's ratings
		#$target_ratings{$movie} = $row[1];
		$target_user_ratings{$row0[0]} = $row0[1];
  	}	
		
	my $get_user_stats = $dbh->prepare('select avg(rating), stddev(rating) from movie_rating where user_id =  ?');
	$get_user_stats->execute("$user");	
	my $user_av_ratings;
	my $user_avstddev_ratings ;
	while ( @stats = $get_user_stats->fetchrow_array ) {

                # This is target user's avg ratings
                $user_av_ratings = $stats[0];
                $user_avstddev_ratings = $stats[1];
        }
	
	$movie_count = @user_movies;
	print "\nCurrent user [$user] has seen $movie_count movies, beginning to cross reference...";

	my $sample;
	if ($movie_count > 500){
		$sample = "limit 700000";
	}elsif(($movie_count < 500) and ($movie_count > 400)){
		$sample = "limit 800000";
	}elsif(($movie_count < 400) and ($movie_count > 300)){
                $sample = "limit 900000";
	}elsif(($movie_count < 300) and ($movie_count > 200)){
                $sample = "limit 1000000";
	}elsif(($movie_count < 200) and ($movie_count > 100)){
                $sample = "limit 1100000";
	}
	# Else no limit...		
	
	#print "Sample is $sample\n";
	

	# Randomize sample
	@user_movies = shuffle(@user_movies); 
	$first_movie = $user_movies[0];
	$get_seer_moviesq = "select user_id, rating, movie_id from movie_rating where user_id != $user and (movie_id = $first_movie";
	foreach $seer_movie (@user_movies) {
                if ($seer_movie != $movie){
                        $get_seer_moviesq = "$get_seer_moviesq or movie_id = $seer_movie";
                }
        }
        $get_seer_moviesq = "$get_seer_moviesq ) $sample";

	$get_seer_movies = $dbh->prepare("$get_seer_moviesq");
	$total_seers = $get_seer_movies->execute();

	while ( @row1 = $get_seer_movies->fetchrow_array ) {

                # This is seer's ratings
		$seer_user_id = $row1[0];
                $seer_user_ratings{$seer_user_id} = $row1[1];

		$seer_rating = $row1[1];
                $seer_movie = $row1[2];

		# Going through list of all movies seen by both seer and user
		$count = 0;
               	$count++;

		# Get the delta
		$user_rating = $target_user_ratings{$seer_movie};
		$seer_rating_delta = abs($user_rating - $seer_rating);
		$total_seer_rating_delta{$seer_user_id} = $total_seer_rating_delta{$seer_user_id} + $seer_rating_delta;

        	$seer_user_hit_count{$seer_user_id} = $seer_user_hit_count{$seer_user_id} + 1;

	}

	for my $seer (keys %seer_user_hit_count){
		my $percentage_hit =  $seer_user_hit_count{$seer}/$movie_count;
		my $predictor_value = $total_seer_rating_delta{$seer} / $percentage_hit;

		if (($predictor_value == 0) and ($percentage_hit < .05)){
			delete $seer_user_hit_count{$seer};
			delete $total_seer_rating_delta{$seer};	
		}
		else{
			$predictor_value_hash{$seer} = $predictor_value;
		}
	}
        # Calculating the top percentage of seers to use
        my $number_of_valued_predictors;
        $number_of_valued_predictors = keys (%predictor_value_hash) * .00001 ;
	# Round the number
	$number_of_valued_predictors = int($number_of_valued_predictors + 5);

	my @sorted_predictor_value_keys_by_value; 
        @sorted_predictor_value_keys_by_value = sort { $predictor_value_hash{$a} <=> $predictor_value_hash{$b} } keys %predictor_value_hash;

        # Shorten the array by the number that we are interested in
        $#sorted_predictor_value_keys_by_value = $number_of_valued_predictors;

	$predictor_numbers = @sorted_predictor_value_keys_by_value;

	my $weight_count;
	my $weight;
	my $value;
	my $total_value_calc;
	my $total_weight_calc;
	foreach my $seer_uid (@sorted_predictor_value_keys_by_value){
			
		$weight_count++;
                $seer_rating = $seer_user_ratings{$seer_uid};
		$weight = $predictor_numbers / $predictor_numbers + $weight_count;	
		$total_weight_calc = $total_weight_calc + $weight;
		$value = $weight * $seer_rating;
                $total_value_calc = $total_value_calc + $value;
        }

        $seer_rating_average = $total_value_calc/$total_weight_calc ;

	my $uar_weight; 
	if ($user_avstddev_ratings != 0){
		$uar_weight = 1 / $user_avstddev_ratings;
	}
	else{
		$uar_weight = 1000000;
	}
	my $uar_value ;
	$uar_value = $uar_weight * $user_av_ratings; 

	my $std_dev_weighted_average ;
	$std_dev_weighted_average = ($seer_rating_average + $uar_value) / (1 + $uar_weight);
	
#	print "Using the top $predictor_numbers similar users to compare against\n";
#	print "User's standard deviation is $user_avstddev_ratings, user's average rating is $user_av_ratings";
#	print "Seer Average calculation is ($total_value_calc/$total_weight_calc)\n";
#	print "SD Weighted average calculation is ($seer_rating_average + $uar_value) / (1 + $uar_weight)\n" ;
#	print "Average seer rating: $seer_rating_average \n";
#	print "Weighted average seer rating: $std_dev_weighted_average  \n";

	

	if ($user_avstddev_ratings < .5){
		$std_dev_weighted_average = int($std_dev_weighted_average + .5);
#		print "Returned user standard deviation included value\n";
		# Prediction, std, user average, seer average, whether std was used in prediction
		return($std_dev_weighted_average,$user_avstddev_ratings,$user_av_ratings, $seer_rating_average, STD);
	}	

    	$seer_rating_average = int($seer_rating_average + .5);	
	return($seer_rating_average,$user_avstddev_ratings,$user_av_ratings,$seer_rating_average,NSTD);
}
