# Guidelines for 1st level analyses

In the first-level analysis in SPM, 3 types of input have to be recorded: onset times, preprocessed images and realignment parameters. 

## Onset times
Before you start working on the first-level analysis in SPM, you have to have the onset times per event in a .mat file, in a specific order. There should be one .mat file per run, per subject (24 subjects x 2 runs would amount to 48 .mat files).

If you programmed your task in Presentation or Matlab:
-It is then useful to code this as part of the task, so that onset times will be written to a .mat file at the time of data collection.

If you programmed your task in E-prime:
-In this case, there is an Eprime2SPM matlab script available that extracts the onset times from E-prime output and produces the right .mat files.

## Realignment parameters
For the first level analysis, we use the realignment parameter .txt files derived from the combine script. 
However, it is important to notice that these files contain 30 extra observations that have to be removed before you enter them as multiple regressors in the first level batch. 

## Setting up the first level in SPM
Set up the first level analysis for one person first, and check whether it works. If it does, you can choose the option Save batch and script. The code_batch script on groupshare will make a .mat file for every participant, based on the example for one participant. To run the first level script for all participants, click Specify first level and select the .mat files of every participant. 

Apart from the factorial design specifications specified below, add a model estimation module that takes the SPM.mat file from the factorial design as a dependency. Make sure you also add a contrast manager.

When running the first level analysis, a design matrix is produced for every participant. The parameter estimability bar should not contain any gray cells. 

See the image below for the first level parameters:

![](images/first_level_parameters.jpg "First level parameters")

Note:
"(...) you should be aware that moving files around is only ok for
preprocessing. Since SPM stores full paths to data files in its
statistics data file SPM.mat, moved files will be a problem for e.g.
plotting time courses in statistical analysis."
Be aware that the same applies for the second level analyses.