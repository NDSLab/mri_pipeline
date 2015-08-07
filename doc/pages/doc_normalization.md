# Normalization #

## Background ##

When you normalise your images, they are transformed to standardized (MNI) space. The images are aligned to a standard template image, which is an averaged scan of many subjects. Transforming the data of all subjects to the same space makes it easier to compare subjects with each other. 

This step must be done twice: once for the functional scans, and once for the structural scans. 

For the voxel size, look at your scan parameter list, but also take the *slice gap into account*! Look up the voxel size and distance factor (a percentage) on the list, and enlarge the last dimension of the voxel by this percentage. For example, if the voxel size is 3.5 x 3.5 x 3.0 mm according to the scan parameter list, and the distance factor is 17%, the voxel size to be entered is 3.5 x 3.5 x 3.5 mm. 

Note: we can choose any voxel size at this step. So, even if we aquired the data with 3mm isometric, we could choose to write the normalized images with 1mm isometric. However, we choose to stay at the same resolution as the original image, to minimize interpolation and data-issues (1mm isometric images take up much more memory than 3mm isometric).

We use the SPM12 default settings for this step. 

## How to ##

First follow the preparation steps in the [Getting Started guide](howto_getting_started.md).

This is step is performed by the SPM batch `spmbatch_preprocessing.m`, which you call using `PreprocessSubject()`.
