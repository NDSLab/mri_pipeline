


% human readable requirements for single job:
memory_in_GB = .005;
time_in_hours  = 1/60;

cfg.memreq = memory_in_GB * 1024 *1024 * 1024;
cfg.timreq = time_in_hours * 60 * 60;

addpath /home/common/matlab/fieldtrip/qsub
addpath .. % ie the analysis_mri/utils folder


% assert prologue & epilogue scripts are in expected place
assert(exist('~/bin/torque_prologue.sh','file')==2,'Error: prologue script not found. Run analysis_mir/utils/install_torque_scripts.sh\n For more details see example_working_dir in the utils folder.');
assert(exist('~/bin/torque_epilogue.sh','file')==2,'Error: epilogue script not found. Run analysis_mir/utils/install_torque_scripts.sh\n For more details see example_working_dir in the utils folder.');

% submit one job 
qsubfeval(@simple_job, 5, 'memreq', cfg.memreq, 'timreq', cfg.timreq,...
    'options','-l prologue=~/bin/torque_prologue.sh -l epilogue=~/bin/torque_epilogue.sh');
