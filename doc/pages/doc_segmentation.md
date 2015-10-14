# Segmentation #

## Background ##

During the segmentation step, your structural images are separated into grey matter, white matter, and CSF. Your images are compared to standard SPM tissue probability maps. These tissue probability maps can be found in `/home/common/matlab/spm12/tpm`. Bias correction will remove any slow varying intensity.

We use the bias-corrected structural image for coregistration with the mean image of the functional images. 

We are using the default SPM12 settings for this step, using the tissue probabilty maps provided by SPM12. 


After segmentation, several new images have been created in the structural folder. The prefixes tell you which procedures the images have undergone. 

| Prefix | Image                                 |
|-------:|:--------------------------------------|
| c1     | segmented grey matter                 |
| c2     | segmented white matter                |
| c3     | segmented CSF                         |
| c4     | bone                                  |
| c5     | soft tissues                          |
| y      | deformation fields, for normalization | 
| s      | original structural image             |
| ms     | bias corrected image                  |
| wms    | normalized, bias corrected image (will be created during[normalization](doc_normalization.md))     |


In addition. a `s.._seg8.mat` file is written to the folder.

Note: use the `y_...nii` deformation fields to normalize both your structural, and your functional images. If you have to run some analysis on the original, not-normalized images of each subject (e.g. search-light MVPA), you can use the deformation fields to warp your results into MNI space, before performing any group analysis. 

## How To ## 

First follow the preparation steps in the [Getting Started guide](howto_getting_started.md).

This is step is performed by the SPM batch `spmbatch_preprocessing.m`, which you call using `PreprocessSubject()`.