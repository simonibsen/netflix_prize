#!/usr/bin/perl 

use DBI;
use List::Util 'shuffle';


#
# Set up DB connections
#
	my $dbh = DBI->connect("DBI:mysql:nfp", "nfp", "secret");
	my $get_rating = $dbh->prepare('select rating from movie_rating where `movie_id` = ? and `user_id` = ? limit 1');


open(PROBE, "< /home/simon/eci.home/np/probe.txt") || die "can't read: $!\n";
while (<PROBE>){
	chomp;
	if(/.*\:$/){ 	
		($movie_id) = (split /:/, $_);	
		$movie_number++;
		$percdone = $numValues/1425333;
		print "#$movie_number -- Movie ID: $movie_id -- PERCENTAGE DONE: $percdone % \n";
	}
	else{
		$user_id =  $_;
		
		$get_rating->execute("$movie_id", "$user_id");
		@get_rating_response = $get_rating->fetchrow;
		$rating = $get_rating_response[0];

		$prediction = &predict_rating($movie_id, $user_id);
		print "$prediction => $rating (Prediction => Actual) for $movie_id \n";
		my $delta = $rating - $prediction;
		$numValues++;
		$sumSquaredValues += $delta*$delta;

	}
	if ($numValues != 0){
		printf "%d pairs RMSE: %.5f\n", $numValues, sqrt($sumSquaredValues/$numValues);
	}
}
close(PROBE);

sub predict_rating {
	my $movie =  $_[0];
	my $user = $_[1];
	
	# We want to get reliable predictors	

	# get all movies for this user
	# find users with the most set of same movies + and that has seen $movie
	# find users with the smallest absolute value delta - these are the predictors

	# Get other all movies this user has seen
	my $get_user_movies = $dbh->prepare('select movie_id,rating from movie_rating where user_id = ?');
	$get_user_movies->execute("$user");	
	
	my @user_movies;
	my @row0;
	my %target_user_ratings;
	while ( @row0 = $get_user_movies->fetchrow_array ) {
		# These are the movies
		push @user_movies, $row0[0]; 

		# This is target user's ratings
		$target_user_ratings{$row0[0]} = $row0[1];
  	}	
		
	
	my $movie_count;
	$movie_count = scalar(@user_movies);
	print "This user has seen $movie_count movies, beginning to cross reference...";

	# Get everyone who has seen the movie in question

	my $total_seers;
		
	my $seer_user_id;
        my %seer_user_ratings;
        my $total_seer_rating_delta;

        my $seer_rating_average_calc;
        my $seer_rating;

	my %predictor_value_hash;

       	my $count;


	@user_movies = shuffle(@user_movies); 
	$first_movie = $user_movies[0];
	my $get_seer_moviesq;
	$get_seer_moviesq = "select user_id, rating, movie_id from movie_rating where user_id != $user and (movie_id = $first_movie";
	foreach $seer_movie (@user_movies) {
                if ($seer_movie != $movie){
                        $get_seer_moviesq = "$get_seer_moviesq or movie_id = $seer_movie";
                }
        }
        $get_seer_moviesq = "$get_seer_moviesq ) limit 750000";

	$get_seer_movies = $dbh->prepare("$get_seer_moviesq");
	$total_seers = $get_seer_movies->execute();
	while ( @row1 = $get_seer_movies->fetchrow_array ) {

                # This is seer's ratings
		$seer_user_id = $row1[0];
                $seer_user_ratings{$seer_user_id} = $row1[1];

		$seer_rating = $row1[1];
                $seer_movie = $row1[2];

		# Going through list of all movies seen by both seer and user
        	my $count;
		$count = 0;
                	$count++;

			# Get the delta
			$user_rating = $target_user_ratings{$seer_movie};
			$seer_rating_delta = abs($user_rating - $seer_rating);
			$total_seer_rating_delta{$seer_user_id} = $total_seer_rating_delta{$seer_user_id} + $seer_rating_delta;

		
		$secount++;
		my $percentage_hit =  $count/$movie_count;
	

		my $predictor_value = $total_seer_rating_delta{$seer_user_id} / $percentage_hit;
		$predictor_value_hash{$seer_user_id} = $predictor_value;

	        }
        # Calculating the top percentage of seers to use
        my $number_of_valued_predictors;
        $number_of_valued_predictors = $total_seers * .1 ;
	# Round the number
	$number_of_valued_predictors = int($number_of_valued_predictors + .5);

        #$predictor_value_hash{$seer_user_id} = $predictor_value;
	my @sorted_predictor_value_keys_by_value; 
        @sorted_predictor_value_keys_by_value = sort { $predictor_value_hash{$a} cmp $predictor_value_hash{$b} } keys %predictor_value_hash;

        # Shorten the array by the number that we are interested in
        $#sorted_predictor_value_keys_by_value = $number_of_valued_predictors;

	foreach $seer_uid (@sorted_predictor_value_keys_by_value){
                $seer_rating = $seer_user_ratings{$seer_uid};
                $seer_rating_average_calc = $seer_rating_average_calc + $seer_rating;
        }


        $seer_rating_average = $seer_rating_average_calc / $number_of_valued_predictors;

    	$seer_rating_average = int($seer_rating_average + .5);	
        return($seer_rating_average);
}
