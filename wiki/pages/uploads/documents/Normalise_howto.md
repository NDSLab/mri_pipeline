#Preprocessing
===============
##Normalise Write
---------------

###How to do it

This step must be done twice: once for the functional scans, and once for the structural scans. 
For the voxel size, look at your scan parameter list, but also take the slice gap into account! 
Look up the voxel size and distance factor (a percentage) on the list, and enlarge the last dimension of the voxel by this percentage. For example, if the voxel size is 3.5 x 3.5 x 3.0 mm according to the scan parameter list, and the distance factor is 17%, the voxel size to be entered is 3.5 x 3.5 x 3.5 mm. 



####Normalisation Parameters
![Normalisation parameters] (mri_pipeline/wiki/pages/uploads/images/normalise write parameters.jpg)