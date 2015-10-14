# Combining Multi-echo data #

This describes the combinig step of the preprocessing pipeline, executed by `CombineSubject.m`.

## Background ##


Most data acquired at the Donders is multi-echo data. Per scan pulse, multiple volumes are acquired (usually four or five). Using a multi-channel head-coil allows us to skip measuring all k-lines and instead interpolate them from the different receiver channels. This means that acquiring a whole volume takes so little time that we have time to measure multiple times during a single excitation pulse. This means that data is acquired at different points along the T2 decay curve. Different tissues have different T2 decay rates, so in one echo, signal intensity could be still high in some tissues, while it has already dropped in others. Usually, researchers have to pick their echo-time depending which parts of the brain they want to focus their analysis on. To avoid having to choose a specific echo, we collect signal from different echoes. However, that also means, we get multiple volumes for each TR, with the signal of interest being spread across these volumes - for one brain region it might be in the first echo, while for another in the third.

However, most analysis software (SPM, FSL, etc.) is written with a single-echo dataset in mind. To avoid having to (re-)write those packages for multi-echo data, we instead combine all the echoes into a single image. The combining happens using a weighted-average procedure (Poser, 2006): in each voxel, a weighting is calculated based on the signal properties of that specific brain region. We use so-called *prescans* to calculate the weights and apply them to all acquired volumes (for that run). 

Note: the scripts assume you have prescans for each run. That is, if you specify that you want 30 volumes to calculate the weights, the script will take the first 30 volumes **of each run** to calculate the weights for that run. **Importantly:** participants should not (yet) be performing a task during these scans.

Since we want to weigh the echoes differently depending on the local brain tissue properties, we must be sure that a voxel at one timepoint corresponds to the same location at another timepoint. In other words, we need to realign images to each other. For this we use SPM 12 realignment which uses a rigit-body transformation. That is, it assumes that the only thing needed to match up two images is to translate and rotate one of the images. The realignment step simply estimates how much each images needs to be moved and rotated. In a second step, reslicing, new images are calculated by interpolating the activity, so that the new voxels in two images match in location.

Note: the realignment & reslicing is done the same way as when using the SPM GUI and specifing runs as 'sessions': You first realign the first volumes of each run to each other, then within runs. Here, the double-pass procedure is used at both steps. Reslicing takes all images at the same time (ignoring runs) and resamples the images. That is, new values are interpolated, so that the same voxel in two different images corresponds to the same location in the brain.  This also calculates a single mean (ie slightly different then the ones you aligned to, because those were only calculated per run/between the first volumes across runs) and writes it to file.

We assume that participants do not move too much between echoes.  Thus, the script calculates the realignment parameters only for the first echo volumes and use the same parameters to realign all the other echoes. The advantage of using the first echo for estimating is that it has the most signal overall, so the rigid-body transformation should be most accurate on that echo.

Final note: Some head-coil calibration scans are done before you get your first images (to make the k-line interpolation, and thus, multi-echo data possible). This means you don't need to discard any volumes from your analysis (like you might read in papers using single-echo sequences, saying e.g. "we discarded the first 5 volumes from our analysis to account for T1 effects").

*Reference:*
	Poser, B. a, Versluis, M. J., Hoogduin, J. M., & Norris, D. G. (2006). BOLD contrast sensitivity enhancement and artifact reduction with multiecho EPI: parallel-acquired inhomogeneity-desensitized fMRI. Magnetic Resonance in Medicine : Official Journal of the Society of Magnetic Resonance in Medicine / Society of Magnetic Resonance in Medicine, 55(6), 1227–35. doi:10.1002/mrm.20900


## How to use the script ##

### Preparation ###

First follow the preparation steps in the [Getting Started guide](howto_getting_started.md).

Be sure to place the raw data (DICOMs, i.e. `.IMA` files) inside the `data_raw` folder, inside the subject's folder (e.g. `3014030.01/3014030.01_petvav_001_001/data_raw`). 

Check that your `scans_metadata.m` has the correct info for that specific subject (see comments inside the file for where to get the info from).

### Running the script ###

In an interactive Matlab session, run something like:

```matlab
% change directory to be where the scripts are, for example:
cd '~/projects/3014030.01/analysis_mri/1_preprocessing'
% run analysis for a specific subject, e.g. 6
CombineSubject(6);
```

Alternatively, you can batch several subjects (or even a single subject if you want to use your interactive session for something else). For that, edit the `subjects` array at the beginnig of `batch_CombineSubject.m`. Once done, simply run the script (e.g. hit `F5` while you are in the file in the editor).

### Outcome ###

After running `CombineSubject.m` with the default settings, you will have:

1. converted the DICOM images to Nifti format

2. run [spike detection](doc_spike_detection.md) on these (results saved in folder `data_quality_checks` inside the subjects folder)

3. realigned & resliced all images, of all runs
Specifically, you realigned the first echo images as if you had done that using the SPM GUI (i.e. first, the first images of each run to each other, then within each run, and the whole thing using a double pass procedure). This will also have created a set of `rp_f...txt` files (as many as runs) which contain the motion regressors and a mean image `meanf...nii`). Then, those realignment parameters were applied to all the other echoes. Finally, the realigned images are resliced and saved with a 'r' prefix (per default, not on your M-drive).

4. calculated weights for each run separately (combining weights are saved in `CombiningWeights.mat`) using the first 30 (per default) volumes 

5. applied the weights to all volumes. The new, combined images are saved using a 'c' prefix (for 'combined')

6. everything that was written to the console during the matlab session was saved to a log file (e.g. `combineSubject_s6.log` inside the `analysis_mri/1_preprocessing/logs` folder)

7. per default, only the final `crf...nii` images will be put into the subject's `data_preprocessed` folder

Note: Previous versions of the combining scripts moved the prescans (the volumes used to calculate the weights) into a seperate folder. Typically, people did not include them into their first-level GLM. However, there are no reasons to do so. You can simply leave the 30 volumes with the rest of the functional images of that run. Actually, by doing so, you will improve the estimation of the nuisance regressors - more data is better. 