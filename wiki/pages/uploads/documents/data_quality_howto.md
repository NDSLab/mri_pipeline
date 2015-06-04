#Checking data quality
========================
## Running the scripts
------------------------

There is a centre-wide script, which makes a movie of your scans, and checks for movement and spikes. 

Change the parameters in bch_check_movie_runwise.m, bch_check_signal_runwise.m,  and bch_check_spike_runwise.m. Then run batch_spm5.m. 

Various images and movies are created in this step, and they all tell you something about the quality of your data. 

These scripts should be done per run, otherwise your results will look strange.  