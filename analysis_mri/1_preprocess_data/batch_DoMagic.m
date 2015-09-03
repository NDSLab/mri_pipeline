function batch_DoMagic
%BATCH_COMBINESUBJECT combine multi-echo images, for several subjects, by
% submitting each subject as a different job to the torque-clustersubjects = 2:3; % array of integers
subjects = [12];


% human readable requirements for single job:
memory_in_GB = 4;
time_in_hours  = 3;

cfg.memreq = memory_in_GB * 1024 *1024 * 1024;
cfg.timreq = time_in_hours * 60 * 60;

addpath /home/common/matlab/fieldtrip/qsub
if ~isempty(subjects)
    for s = subjects
        % define job id (used for log files produced by torque job, ie. the
        % *.e129386 and .o92856 
        batchId = sprintf('doMagicLog_%03.0f_001_%s', s, datestr(now,30));
        
        % submit one job at a time
        qsubfeval(@DoMagic, s, 'memreq', cfg.memreq, 'timreq', cfg.timreq, 'batchid', batchId);
    end
end
end
