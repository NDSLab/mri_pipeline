# Smoothing #

## Background ##

This step spatially smoothes your functional images. The main reason to do this is that spatial normalization doesn't work perfectly. To be able to compare across subjects, we give up a little spatial specificity, but gain a bit signal-to-noise ratio. 

For the FWHM, choose a size equal to 2-3 times your voxel size. You could check this on an irrelevant contrast. 

## How to ## 

First follow the preparation steps in the [Getting Started guide](howto_getting_started.md).

This is step is performed by the SPM batch `spmbatch_preprocessing.m`, which you call using `PreprocessSubject()`.