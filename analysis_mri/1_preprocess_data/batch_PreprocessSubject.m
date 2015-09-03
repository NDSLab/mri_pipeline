function batch_PreprocessSubject
% batch_PreprocessSubject preprocess combined data, for several subjects,
% by submitting each subject as a different job to the torque-cluster
subjects = 4; % array of integers

% human readable requirements for single job:
memory_in_GB = 3;
time_in_hours  = 2;

cfg.memreq = memory_in_GB * 1024 *1024 * 1024;
cfg.timreq = time_in_hours * 60 * 60;

addpath /home/common/matlab/fieldtrip/qsub
if ~isempty(subjects)
    for s = subjects
        % submit one job at a time
        qsubfeval(@PreprocessSubject, s, 'memreq', cfg.memreq, 'timreq', cfg.timreq);
    end
end
end


