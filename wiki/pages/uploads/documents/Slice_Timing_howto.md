#Preprocessing
===============
##Slice Timing
---------------

###How to do it

Although the scan parameter list mentions that multi-slice mode is interleaved, slice order cannot be interleaved when using a multiecho sequence. Instead, look at the line below (Series), where it says whether scans were acquired in ascending or descending order. For an example of the scan parameter list, check the image below:

![Scan Parameter List] (mri_pipeline/wiki/pages/uploads/images/scan parameter list.jpg)

####Slice Timing Parameters
![Slice timing parameters] (mri_pipeline/wiki/pages/uploads/images/slice timing parameters.jpg)