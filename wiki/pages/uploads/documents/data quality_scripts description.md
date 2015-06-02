# Checking data quality
========================
## Scripts Description
------------------------

### Bch_check_movie_runwise_percentiles

This script produces two movies per run, a default movie and a contrast movie. The movies show one volume per scan pulse, in the same way as you see your volumes coming in on the Inline display during scanning. The number in the lower right corner corresponds to the number of images on the print list. If the movie produced is too light or too dark, you can adjust the brightness in the default movie, or 'cfg_noise_high'and 'cfg_noise_low' in the contrast movie. In some of the movies, the corners get cut off from the first or last slice of the volume, or the skull can show up in black. This is no problem. 

The default movie shows your actual images, whereas the contrast movie aims at plotting the low intensity noise while overexposing the part of the image you’re actually interested in. The script also produces a histogram, showing you the distribution of intensities of your images. Intensities close to zero are noise, and the cluster further to the right is your actual image. Noise and image intensities should be distinct clusters. 

For an example of how the contrast movie should look like, check the following image:
![Check contrast_Right] (mri_pipeline/wiki/pages/uploads/images/contrast_movie_right.jpg)

For an example of a contrast movie that does not look fine, check the following image:
![Check contrast_Wrong] (mri_pipeline/wiki/pages/uploads/images/contrast_movie_wrong.jpg)
This image shows a still from a contrast movie just before the coil broke down. Data from this participant had to be excluded due to excessive noise in the data. The contrast is lower, and there is a lot of radiation in the horizontal direction.

### Bch_check_signal_runwise

The main output of this script is a .png file containing four graphs. For an example, check the following image:
![Check signal] (mri_pipeline/wiki/pages/uploads/images/signal_runwise.jpg)

The upper left graph shows the mean intensity per volume, per slice. Volume number is on the x-axis, intensity on the y-axis, and every colored line is a different slice. The upper right graph shows the global signal, which is the mean intensity per image. Basically, it is the mean of the lines in the upper left graph. It is also the same as the mean curve that you can see on the scan computer during scanning. The lower panel depicts the variance of the two upper graphs.  

### Bch_check_spike_runwise

This script also plots the intensity per volume and per slice. For an example, check the following image:
![Check spike] (mri_pipeline/wiki/pages/uploads/images/spike_runwise.jpg)

Again, volume number is on the x-axis, and every line is a different slice. In this graph, the intensity of the first slice of the first volume is set to y = 1. There is a dotted line at y = 1.3, which is the spike threshold. If any of the colored lines pass the threshold, a spike has occurred. This should not happen often, certainly not more than once during the same scan session. If you see multiple spikes for one participant, or if you see spikes for a couple of participants in a row, contact Paul. 