function batch_CheckSubject()
%
% Runs CheckSubject.m for an array of subjects.
% Adjust array of subjects

    subjects = [101]; % array of integers

    addpath /home/common/matlab/fieldtrip/qsub
    if ~isempty(subjects)
        for s = subjects
            % submit one job at a time
            feval(@CheckSubject, s);
        end
    end
end

