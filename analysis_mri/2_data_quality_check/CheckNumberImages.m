% get list of all DICOMs, combined and preprocessed images and check
% against expected number of images


diary(sprintf('log_Check_%s.log', datestr(now,30)));
subjects = [1:31 33:40]; nSubjects = length(subjects);

%% check whether number of files as expected
nMissingDicoms = cell(nSubjects,1);
nMissingCombined = cell(nSubjects,1);
nMissingPreprocessed = cell(nSubjects,1);
for subject = subjects
    datestr(now,0)
    nMissingDicoms{subject} = AssertCorrectNumberOfDicoms(subject);
    [nMissingCombined{subject} nMissingPreprocessed{subject}] = AssertCorrectNumberOfNiftis(subject);
end


%% print summary
if any(reshape(cell2mat(nMissingDicoms),[],1))
    fprintf(' some DICOM files are missing\n');
else
    fprintf('no DICOMs missing (or none at all present)\n');
end

if any(reshape(cell2mat(nMissingCombined),[],1))
    fprintf(' some combined files are missing\n');
else
    fprintf('all combined files found\n');
end

if any(reshape(cell2mat(nMissingPreprocessed),[],1))
    fprintf(' some preprocessed files are missing\n');
else
    fprintf('all preprocessed files found\n');
end

diary off