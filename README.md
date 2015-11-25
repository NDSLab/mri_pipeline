mri_pipeline
============

This are scripts used to analyse multi-echo fRMI data in our group at the DCCN. They are based on SPM12 and custom scripts.

A detailed description what those scripts do and how they are to be used can be found here on the wiki (also part of this repository):
http://ndslab.github.io/mri_pipeline/doc/

Note: Use Matlab 2014a or newer.

Change Log
=============

v1.01 
major bug fixes:
* spmbatch_preprocessing.m -> now correctly coregisters structural and functional, and thus normalization works as intended

minor bug fixes:
* typo in RemoveCombinedData.m
* remove reference to localizerSeries
* wrongly set 'keepIntermediaryFiles' in CombineSubject

enhancements: 
* add optional check for number of volumes vs expected number of volumes
* scans_metadata_TEMPLATE.m lists nVolumes array (see above)
* extend .gitignore for SPM.mat, nifti etc. 
* update documentation and minor enhancements
* GetAllDicomNames. throws error if no Dicoms, and a warning series-of-interest not present