# Combining multi-echo images

First, the raw DICOM images are converted to nifti format, so that SPM can work with them.

Then, all images are realigned. Here, we use the first echo to estimate the motion parameters, because it contains most signal overall. Since the motion parameters are calculated for a solid body rotation and translation, we can apply the same ones to the other echoes. 

For multiple runs, we first realign within runs, using SPM's double pass procedure. Then, all images are realigned to each other. Only then os reslicing applied.

The next step calculates the combining weights, using the PAID procedure (Poser, et al. (2006). BOLD contrast sensitivity enhancement and artifact reduction with multiecho EPI: parallel-acquired inhomogeneity-desensitized fMRI. doi:10.1002/mrm.20900). For this, the first 30 images of each run are used. 

