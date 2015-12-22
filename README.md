# netflix_prize
This was a fun problem presented by Netflix
in 2006 (with a million dollar carrot):

https://en.wikipedia.org/wiki/Netflix_Prize

http://www.netflixprize.com/

It became a distributed computing problem in 
addition to a data analysis problem.  There
are many different approaches one could take
to try to solve it, here are just a couple.

- mr-db2.pl - loading the movie rating data into a db 
- rmse.pl - calculating the RMSE of the results
- wrap.csh - shell rapper splitting the load up among systems
- qfx.pl - approach #1 - This approach aims to match up a user's
viewing tastes with someone else who has seen the movie in
question and basing prediction on this.
- wstd.pl - approach #2 - This approach allows for splitting
the job up by taking arguments to selectively work only on
some parts of the data.  It then writes out results to disk.
It also tries to increase performance by imposing limits
on queries.  It calculates std deveations to of user
ratings to try to determine their reliability as 
predictors.
