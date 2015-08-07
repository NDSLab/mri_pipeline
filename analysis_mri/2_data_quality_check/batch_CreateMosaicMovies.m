% Runs CheckSubject.m for an array of subjects.
% Adjust array of subjects
% subjects = [4, 7:11,12:13,15,17:18,23,25:29,33:34,37:39]; % array of integers
subjects = [14,16,19:22,24,30:31,35:36,40];
if ~isempty(subjects)
    for s = subjects
        % submit one job at a time
        CreateMosaicMovies(s);
    end
    
end
