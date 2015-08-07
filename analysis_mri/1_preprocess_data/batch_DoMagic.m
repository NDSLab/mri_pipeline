function batch_DoMagic
% BATCH_DoMagic submit DoMagic(..) for multiple subjects as a torque job by
% submitting each subject as a different job to the torque-cluster.
% E.g.: subjects = 1:13;
subjects = [21]; 

% human readable requirements for single job:
memory_in_GB = 4;
time_in_hours  = 3;

cfg.memreq = memory_in_GB * 1024 *1024 * 1024;
cfg.timreq = time_in_hours * 60 * 60;

% how many subjects to run in one go (to avoid overrunning quota on
% M-drive)
nConcurrent = 6;

addpath /home/common/matlab/fieldtrip/qsub
if ~isempty(subjects)
    
    % submit (e.g.) 6 subjects in one go, then wait for time_in_hours, and
    % then submit next 6 subjects, till done with all
    nSubjectBatch = ceil(length(subjects)/nConcurrent);
    for iBatch = 1:nSubjectBatch
        iStart = nConcurrent * (iBatch - 1) + 1;
        iEnd = min( nConcurrent * (iBatch), length(subjects) );
        currentSubjects = subjects(iStart:iEnd);
        for s=currentSubjects
            % use qsub prologue/epilogue scripts to create/clean up working
            % directory
            % cf analysis_mri/utils
            assert(exist('~/bin/torque_prologue.sh','file')==2,'Error: prologue script not found. Run analysis_mir/utils/install_torque_scripts.sh\n For more details see example_working_dir in the utils folder.');
            assert(exist('~/bin/torque_epilogue.sh','file')==2,'Error: epilogue script not found. Run analysis_mir/utils/install_torque_scripts.sh\n For more details see example_working_dir in the utils folder.');
            
            % define job id (used for log files produced by torque job, ie. the
            % *.e129386 and .o92856
            batchId = sprintf('log_DoMagic_%03.0f_001_%s', s, datestr(now,30));
            
            % submit one job at a time
            qsubfeval(@DoMagic, s, 'memreq', cfg.memreq, 'timreq', cfg.timreq, ...
                'options','-l prologue=~/bin/torque_prologue.sh -l epilogue=~/bin/torque_epilogue.sh',...
                'batchid', batchId);
        end
        
        % pause except on last loop
        if iBatch < nSubjectBatch 
            pause(cfg.timreq);
        end
    end
end
end
