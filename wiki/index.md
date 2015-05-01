# Documentation

## How to use the scripts

[Preparation](pages/preparations.md) consists mostly of defining a few variables which the scripts use, arranging the data according to archiving policy, and installing some simple bash-scripts.

[Running the combine scripts](pages/running_combine.md) can be done either via an interactive matlab session, or by submitting the job to the torque cluster.

## What the scripts do
### Combining multi-echo data

This step converts the images into Nifti format, realigns and reslices using SPM12 procedures, and combines the echoes using the PAID procedure ([more details](pages/combining.md)).


### (standard) SPM preprocessing
This implements [our group's](http://www.decisionneurosciencelab.com) standard preprocessing pipeline ([more details](pages/preprocessing.md)). 