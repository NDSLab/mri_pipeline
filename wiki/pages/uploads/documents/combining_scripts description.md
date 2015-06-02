# Combining multi-echo images
===============================
## Scripts Description
-------------------------------

### The core combine script

This describes how the multi-echo data is combined (by `CombineEcho.m`).

First, the raw DICOM images are converted to nifti format, so that SPM can work with them.

Then, all images are realigned. Here, we use the first echo to estimate the motion parameters, because it contains most signal overall. Since the motion parameters are calculated for a solid body rotation and translation, we can apply the same ones to the other echoes.

For multiple runs, we treat all images as if they would have come from a single run. Given that the realignment is based on a solid body rotation, it shouldn't matter whether they are from the same run or not. 
Realignment is done using SPM's double pass procedure. For convenience, the resulting motion parameter estimates are also saved in separate files, for each run one. 

After that the images are resliced using SPM's reslicing procedure. This adds the 'r'-prefix to the filenames (SPM convention).

The next step calculates the combining weights, using the PAID procedure (Poser, et al. (2006). BOLD contrast sensitivity enhancement and artifact reduction with multiecho EPI: parallel-acquired inhomogeneity-desensitized fMRI. doi:10.1002/mrm.20900). For this, the first 30 images of each run are used.

Then, these weights are applied to all images and saved. Following SPM preprocessing convention, a prefix is added to the filenames: 'c' for combined.

## The wrapper functions
The `CombineSubject.m` and `CombineWrapper.m` scripts use defaults and other scripts to prepare everything for the core combine script. They assume a certain structure and rearrange the files into subfolders.

Specifically, the combined data is stored under `data_combined/run1`, `data_combined/run2`, etc. Each folder also contains a `.txt` file with the six estimated motion parameters from the realignment step. 
In `data_combined` itself, there's the mean image created by the realignment step and also another copy of the motion parameters, but for all runs concatenated. 

