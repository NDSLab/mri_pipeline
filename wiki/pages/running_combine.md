# Running the combine scripts
There are two ways of running the combine scripts:
1. in an interactive matlab session on the torque cluster
2. as a submitted matlab job

In the interactive matlab session, you can simply navigate into the `analysis_mri/1_combine_multiecho` folder and run `CombineSubject(1)` to combine your first subject data. If you want to combine mutliple subject - but in the interactive session - you can use the `loop_CombineSubject.m` script. Just set the `subjects=[..]` array to include the numbers of the subjects you want to combine.

For the second option, you should use the `batch_CombineSubject.m` script. Like with the above loop scripts, simply edit the `subjects=[..]` array to include the numbers of subjects whose data you want to combine. 
