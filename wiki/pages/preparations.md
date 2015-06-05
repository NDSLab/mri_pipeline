# setup of git

You should [make git ignore your data](uploads/documents/git_ignoring_folders.md), especially your imaging data.

# Preparations before using Matlab
1. [setup the prologue/epilogue scripts](HowTo_prologueScripts.md). These enable the use of the local hard disks of the torque nodes, by creating a temporary folder under `/data`. 
2. [structure the data](folder_structure.md) according the archiving policy based folder structure. 
3. you need to add a `scans_metadata.m` file to your `data_raw` folder. Adapt the template `analysis_mri/1_combine_multiecho/scans_metadata_TEMPLATE.m' to match your data. This should match your series numbers as from the printed list from the scanner (i.e. what get by selecting "Print List.." on the Host PC in the scanner room). This enables the scripts to know which DICOM images are functional images and which ones are structural images - automatically.

Note: the script `CombineEcho.m` is actually implementing the combining math. As long as you set the correct variables yourself (e.g. with your own scripts), you can use it without the provided other scripts. Then, you can also avoid going through these preparations.


