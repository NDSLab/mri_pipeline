function [nMissingCombined, nMissingPreprocessed] = AssertCorrectNumberOfNiftis(SUBJECT_NUMBER, SESSION_NUMBER)

if ~exist('SESSION_NUMBER','var')
    SESSION_NUMBER = 1;
end

s = GetSubjectProperties(SUBJECT_NUMBER, SESSION_NUMBER);

nRuns = length(s.runSeries);

for iRun = nRuns:-1:1
    nCombined{iRun} = dir(sprintf('%s/run%i/crf*.nii',s.dataPreprocessedPath, iRun));
    nPreprocessed{iRun} = dir(sprintf('%s/run%i/swacrf*.nii',s.dataPreprocessedPath, iRun));
    
    nMissingCombined(iRun) = s.nVolumes(iRun) - length(nCombined{iRun});
    nMissingPreprocessed(iRun) = s.nVolumes(iRun) - length(nPreprocessed{iRun});
end

if any(nMissingCombined)
    ind = find(nMissingCombined);
    for i=ind
        fprintf('Subject %i - Run %i - UNEXPECTED number of combined images found - %i volume(s) missing\n', SUBJECT_NUMBER, i, nMissingCombined(i));
    end
else
    fprintf('Subject %i - expected number of combined images found\n', SUBJECT_NUMBER);
    
end

if any(nMissingPreprocessed)
    ind = find(nMissingPreprocessed);
    for i=ind
        fprintf('Subject %i - Run %i - UNEXPECTED number of preprocessed images found - %i volume(s) missing\n', SUBJECT_NUMBER, i, nMissingPreprocessed(i));
    end
else
    fprintf('Subject %i - expected number of preprocessed images found.\n', SUBJECT_NUMBER);
end

end