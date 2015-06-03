function batch_CheckSubject()
%BATCH_CHECKSUBJECT runs CheckSubject.m for an array of subjects.
% Unfortunately, CheckSubject cannot be run on a linux machine (because of
% the videos) so you have to run this script on a windows PC.
%
% Usage:    after editing the "subjects" array.open an interactive Matlab
%           session and just hit "F5"

subjects = 1:2; % array of integers

for s = subjects
    feval(@CheckSubject, s);
    
end

