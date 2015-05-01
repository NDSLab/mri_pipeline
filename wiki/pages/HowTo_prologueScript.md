# Setup of prologue/epilogue scripts

while in the `analysis_mri/utils` folder in your console, simply run:
```bash
./install_torque_scripts.sh 
```
This will copy the `torque_prologue.sh` and `torque_epilogue.sh` scripts to your `~/bin` folder and set the correct file permissions.

# How to use the working dir

When submitting a job via matlab (e.g. using `qsubfeval`), you need to add the `options` argument and add the prologue/epilogue scripts.

As an example, this is how the `batch_CombineSubject.m` submits the individual jobs:
```matlab
qsubfeval(@CombineSubject, s, 'memreq', cfg.memreq, 'timreq', cfg.timreq,...
         'options','-l prologue=~/bin/torque_prologue.sh -l epilogue=~/bin/torque_epilogue.sh');
```

