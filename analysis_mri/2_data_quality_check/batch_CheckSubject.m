function batch_CheckSubject()
%BATCH_CHECKSUBJECT runs CheckSubject.m for an array of subjects.
% Unfortunately, torque doesn't want to run the CheckSubject.m script.
% I suspsect because it doesn't handle 
%
% Usage:    open an interactive Matlab session and just hit "F5" after
%           editing the "subjects" array.

subjects = [2 3 7:20]; % array of integers

% 
% % human readable requirements for single job:
% memory_in_GB = 2;
% time_in_hours  = 2;
% 
% cfg.memreq = memory_in_GB * 1024 *1024 * 1024;
% cfg.timreq = time_in_hours * 60 * 60;

addpath /home/common/matlab/fieldtrip/qsub
if ~isempty(subjects)
    for s = subjects
        % submit one job at a time
        feval(@CheckSubject, s);
    end
end
end

