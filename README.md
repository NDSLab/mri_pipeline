mri_pipeline
============

This are scripts used to analyse multi-echo fRMI data in our group at the DCCN. They are based on SPM12 and custom scripts.

A detailed description what those scripts do and how they are to be used can be found here on the wiki (also part of this repository):
http://ndslab.github.io/mri_pipeline/wiki/

Quick-start
===============================

To use these scripts, it's best to clone the repository and make it your project folder. This way, you will be able to get future updates and bugfixes as they are 
published here by simply calling a `git pull`.

To use the most recent version of the scripts, you need to switch to the `devel` branch. 

If you already have a project folder, the fastest way is to clone this repository into a temporary folder and copy its content into your project folder.

```bash
# change into a temporary folder
cd /path/to/temporary/folder

# clone the repository
git clone https://github.com/NDSLab/mri_pipeline.git

# change into the new folder
cd mri_pipeline

# switch to 'devel' branch to use the most recent scripts
git checkout devel

# copy whole content of repository folder into your project folder
# NOTE 1: make sure to use the -n flag to avoid overwritting any existing scripts. 
# NOTE 2: make sure there's no trailing slash for the destination folder! 
cp -n -r . /path/to/project/folder
# in your project folder, run 'git status' to see which files are different
# from the most recent version from github; and run 'git diff' to see 
# how each file differs
```

If you are starting a new project, simply clone into the folder where you would like to have your new project folder to be located in and rename the `mri_pipeline` folder into your project folder name (e.g. 3014030.01, following the DCCN archiving policy).

```bash
# change into folder where you want your new project to be located in
cd /path/to/project/parent/folder

# clone the repository
git clone https://github.com/NDSLab/mri_pipeline.git

# rename folder to what you want it to be called
mv mri_pipelne my_new_project_folder_name

# switch to 'devel' branch if you want to use the most recent code
cd my_new_project_folder_name
git checkout devel
```



Change log
===============

important changes (except bug fixes) are listed below:

* just a place holder for now... 
