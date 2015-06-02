#Preprocessing
===============
##How to do it
---------------

Preprocessing is done in SPM8. In matlab, type addpath('/home/common/matlab/spm8_20110812'). To open SPM, type spm fmri. You can open the sample batch in the Preprocessing folder and modify.
Details on making a batch with file selectors are explained in the OLD How to preprocess your data manual in the Preprocessing folder of the pipeline. Use this manual only as a guide to set up the batch, but follow this pipeline document for the order and settings.
Processes can be added, deleted and replicated in the batch but the order is determined by the order it is added to the script, appending to the end. It cannot be reordered manually.
 
For the Realign and Coregister steps, you can choose the options Estimate, Reslice, or Estimate & Reslice. If you choose the Estimate option, a matrix with transformation parameters is produced but the original images are not altered. The Reslice option will alter your original images, and you are therefore advised not to use it.     

Normally, realignment is part of preprocessing. However, as the images have already been aligned during combining, we don’t have to do it again during preprocessing. 

