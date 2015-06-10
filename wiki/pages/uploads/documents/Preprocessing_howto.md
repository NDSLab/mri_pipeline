#Preprocessing
===============
##How to do it
---------------

Preprocessing is done in SPM12. Before you can run the scripts, you need to do two things:

1. add suffixes 'run1', 'run2', etc. to your images.
2. adapt the `spm_preprocessing_job.m` to match your scan details

To do step 1) you can simply use the `add_suffix_nii.sh` script. This script looks adds the folder where the images are located to the filename of the Nifti image. For example, `crf140610104010DST131221107521945416-0007-00003-000003-01.nii` will become `crf140610104010DST131221107521945416-0007-00003-000003-01.run1.nii` if it's located inside a folder `run1`. So that your shell can find it independent of in which folder you currently are, copy it into your `~/bin` folder first, then simply call it as described at the beginning of the file (usage 3):

```bash
# copy add_suffix.sh to ~/bin folder
cd /path/to/project
cd analysis_mri/utils
cp add_suffix.sh ~/bin

# run it on all subject data
cd /path/to/project
find -type d -name 'run*' | xargs add_suffix_nii.sh
```

To do step 2) you can start SPM12 and start the batch editor. That is, in Matlab, type 

```Matlab
add(../utils);
LoadSPM;
spm fmri
```

Now SPM 12 should be being loaded. Once you see the menu, click the "Batch" button and then the "Load Batch" button. Select the `spm_preprocessing_job.m` inside the `analysis_mri/3_preprocessing` folder. You should see the SPM preprocessing pipeline as it'll be applied to a single subject's data. 

Check the settings whether they match what you want it to be. Adapt especially the "Slice Timing" section - this should differ from the default as you most likely used a slightly different MRI sequence. However, the remaining steps (e.g. normalization)  should be fine as they are. 

Once you are satisfied it looks like you want it, select "View" from the menu and then "Show .m Code". A new window will pop up, where a `matlabbatch` struct variable is being defined. Right-click to select all and copy-paste this into the `spm_preprocessing_job.m` file. 

You should be able to run this batch directly from the Batch Editor, however you first must convert the structural DICOMs to Nifti. This is done with the `spm_structural_job.m`. Load this file like you did with the other one, adapt the folder paths, and hit the "Run Batch" button. Once you are done, load the `spm_preprocessing_job.m` again, make sure the folders point to the right subject and hit the "Run Batch" button. 
If no errors occured, you should have preprocessed your first subject. 

To do this for, e.g. subject number 2, simply run PreprocessSubject.m by calling `PreprocessSubject(2)` from the Matlab console. This scripts takes the two jobs you looked at in the Batch Editor, overwrites some subject-specific parameters (e.g. subject folder paths) and runs it. If you want to batch multiple subjects and run preprocessing on the torque, just adapt the `subjects` array inside `batch_PreprocessSubject.m` and hit F5 to run that script.
