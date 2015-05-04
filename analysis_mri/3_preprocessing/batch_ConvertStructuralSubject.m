function batch_ConvertStructuralSubject
%BATCH_COMBINESUBJECT combine multi-echo images, for several subjects, by
% submitting each subject as a different job to the torque-cluster
subjects = [26:31 33:40]; % array of integers

% human readable requirements for single job:
memory_in_GB = .5;
time_in_hours  = 3/60; % only 3 minutes -- in interactive session it takes ca 67 seconds

cfg.memreq = memory_in_GB * 1024 *1024 * 1024;
cfg.timreq = time_in_hours * 60 * 60;

addpath /home/common/matlab/fieldtrip/qsub
if ~isempty(subjects)
    for s = subjects
        % submit one job at a time
        qsubfeval(@ConvertStructuralSubject, s, 'memreq', cfg.memreq, 'timreq', cfg.timreq);
    end
end
end


