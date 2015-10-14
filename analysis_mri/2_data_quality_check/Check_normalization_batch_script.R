# -----------------------------------------------------------------
# To automatize at least a very basic normalization check, we create a simple plot of the MNI template overlayed with the subject's normalized structural image using MRIcron.
# 
# This script creates a .bat file, that passes code to the command line. 
# Via the command line, we open MRIcron, have a 5-second time-out to allow 
# time for MRIcron to get ready, make a screenshot, and then we close MRIcron again.   
# The procedure is repeated for every participant.  
#
# Follow the steps in this script to do so as quickly as possible (go to section "INSTRUCTIONS")
# 
# -----------------------------------------------------------------
# -----------------------------------------------------------------
# DOCUMENTATION 
# -----------------------------------------------------------------
# Example of code passed to command line:
#
## * Open MNI-template in MRIcron, with participant's structural scan as overlay 
## start /MAX mricron avg152T1.nii -c -0 -b 40 -o "M:\Oxytocin & SVO\Combined\501\structural
## \wms110110124218STD131221107523235034-0003-00001-000192-01.nii" -c -1 x
##
##        start /MAX mricron: launches MRIcron, and 
##        ensures that the main window is maximized to fill the entire screen
##        avg152T1.nii -c -0 -b 40 : opens avg152T1.nii (MNI template) 
##              -c specifies color (-0 is grayscale), 
##              -b sets transparency of overlays (to 40% in this case)
##        -o overlay_image : open overlay image
##              -c specifies color (-1 is red)
##        x : adjusts the proportions of the sagittal, coronal and axial panels so that each of 
##        these views will be shown at a similar scale. 
##
##
## * Wait for 5 seconds (it takes a while for MRIcron to open)
## timeout 5
##
## * Make a screenshot and save it 
## screenshot-cmd -o "M:\Oxytocin & SVO\Normalization check\501.png"
##
## * Close MRIcron
## nircmd closeprocess MRIcroN
#
# More info on batches for MRIcron at http://www.mccauslandcenter.sc.edu/mricro/mricron/bat.html
# 
# NOTE: In the R-code below, quotation marks (") and backslashes (\) have to be escaped by placing 
# a backslash in front of them. Alternatively, they can be surrounded by single quotation marks (') 
# The extra slash and single quotation marks do not show up in the .bat file. You can check the 
# content of the .bat file by right-clicking it and then selecting Edit. 

# Veerle van Son - NDSL - February 2014
# ADAPTATION by Peter Vavra (October 2015)
# -----------------------------------------------------------------
#
# -----------------------------------------------------------------
# INSTRCUTIONS: 
# -----------------------------------------------------------------
# 1) Get MRIcron from our groupshare folder:
#   Go to G:\decision and copy paste MRIcronPlusPlus.zip into the folder where this script is, and extract it's content there.
# 
# 2) Create a list of filenames (full path) of the structural images
#    I (Peter) have used the linux-shell to create structural_filenames.txt using the following code (replace the /home/decision/.... part with the folder your data is in): 
# 
#       find /home/decision/petvav/projects/3014030.01 -name "wms*.nii" | sort  > structural_filenames.txt
# 
# Then, using a text-editor I've replaced /home/decision/petvav with M:\ and all "/" with "\" to make it windows compatible
# 
# 
# 3) Import filelist as a dataframe into R:
#     I imported it in RStudio using the gui ("Import Dataset") and ran the below lines
#
# 
# 4) Run the script section below:
#     See comments for additional instructions
# 

structural_filenames$mricron <-  paste("start /MAX mricron avg152T1.nii -c -0 -b 40 -o", structural_filenames$V1 , "-c -1 x", sep=" ")

# add subject numbers, one per line - I didn't have subject 32. This will be used for the filenames of the created images.
structural_filenames$subjectNumber <- c(1:31,33:40)


timeout = "timeout 5"
screenshot = paste("screenshot-cmd -o Normalization_check_subject_",structural_filenames$subjectNumber ,".png",sep="")
closeMRIcron = "nircmd closeprocess MRIcroN"
structural_filenames$command <- paste(structural_filenames$mricron, timeout, screenshot, closeMRIcron, "\n\n", sep = "\n")


# The following lines will create the .bat file - in your current folder, so make sure you are in the right place
setwd("M:/projects/3014030.01/analysis_mri/2_data_quality_check")


batch_filename = "normalization_batch.bat"
normalization_batch = write.table(structural_filenames$command, file=batch_filename, quote=F, row.names=F, col.names=F)

#
#
#
# 5) You are done with R. Run the batch from the windows command line, or by double-clicking on it.
#  Leave your computer run without working on it yourself, to avoid that wrong screenshots get taken. This will take roughly 5 seconds * number of subjects, so even for 40 subjects, it's less than four minutes.
# 