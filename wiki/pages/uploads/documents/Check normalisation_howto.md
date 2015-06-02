#Check Normalisation and Registration
===============
##How to do it

---------------

Checking normalization can be done in MRIcron. Here, you can overlay the structural image of a participant on the MNI template. 
 
If normalization seems to have gone wrong, click the Display button in SPM, and select the structural .nii image starting with s. Place the crosshair in the anterior commissure (see the picture below).  

![Check Normalisation] (mri_pipeline/wiki/pages/uploads/images/check normalisation.jpg)

Under crosshair position, look at the position in mm. Multiply these numbers with -1, and enter them for the right, forward and up positions. Click Reorient images to save the new home position of the crosshair for the ^s structural image AND all the slice-timed functional images (^a). After saving, set the crosshair position to 0 0 0 to check the position. Now, redo segmentation, normalization and smoothing for this participant. 


