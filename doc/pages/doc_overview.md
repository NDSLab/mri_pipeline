# Overview of Preprocessing Steps #

Note: follow the preparation steps in the [Getting Started guide](howto_getting_started.md#Preparation) before running the scripts.

To preprocess your imaging data you need to go through the following steps:

1. Convert DICOMs of the functional scans to Nifti file format

2. Realign and Reslice images

3. Combine multi-echo images into a single image

4. Slice time correct

5. Convert the DICOMs of the structural image to Nifti file format

6. Segment the structural image

7. Coregister structural image and functional images

8. Normalize structural and functional images

9. Smooth functional images


**Steps 1-3** are performed by [`CombineSubject()`](doc_combining.md) and the remaining **steps 4-9** are performed by [`PreprocessSubject()`](doc_preprocess.md).

There is also a convenience function `DoMagic()` which calls these two steps in succession, and calls additional quality check scripts at the appropriate time.

All three functions take the *subject number* and the *session number* as their input, and figure out the rest automagically, assuming you followed the [preparation steps](howto_getting_started.md#Preparation) 

For all three functions, there is also an associated `batch_..` script which allow you to run the associated function in parallel, by submitting them to the torque cluster. You only need to edit the `subjects=[..]` array at the beginning of them. Running those scripts will submit each subject as an individual job to the torque cluster. The resource requirements (memory and walltime) were generously(?) estimated using a dataset consisting of three runs of about 50 minutes total scanning time. If you have substantially longer scanning sessions, you might need to adjust those (esp. the walltime).