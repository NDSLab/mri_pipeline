# Coregistration #

## Background ## 

During coregistration, the functional and structural data from individual participants are aligned. Only rigid body transformations are performed: translations in x, y and z directions, and rotations over x, y and z axes. This is like the [realignment during combining](doc_combining.md), but also works for different image types (i.e. structural and functional), while the realignment step assumes the same type of images (e.g. only functional). 

The reference image stays stationary (mean functional image), while the source image (the structural image) is moved around to match the reference image.

We do it this way, because we already realigned all the functional images to each other during combining. This way, we don't move all of them again. Instead, we move the structural image. 

Once we have coregistered the structural and functional images, and we calculated how we need to deform the subject's images to match the MNI template (ie calculated the normalization), we can apply the deformation fields and normalize both the [structural and the functional images](doc_normalization).

<!-- CHECK: During this step, actually only the header information of the images is changed - the image data itself is not altered. --> 

## How To ## 

First follow the preparation steps in the [Getting Started guide](howto_getting_started.md).

This is step is performed by the SPM batch `spmbatch_preprocessing.m`, which you call using `PreprocessSubject()`.
