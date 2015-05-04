% List of open inputs
function ConvertStructuralSubject(subjectNumber,sessionNumber)
t=tic;
% set default session number
if ~exist('sessionNumber','var')
    sessionNumber=1;
end

% prepare SPM12
addpath('/home/common/matlab/spm12');
spm('defaults', 'FMRI');
spm_jobman('initcfg');

% get subject specific meta-info
addpath('../utils');
s = GetSubjectProperties(subjectNumber, sessionNumber);

% load matlabbatch variable
run('spm_structural_job.m');

% overwrite subject-specific job-stuff
matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_named_dir.dirs = {{s.dataRawPath}};
matlabbatch{3}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.parent = {s.subjectFolder};
matlabbatch{2}.cfg_basicio.file_dir.file_ops.file_fplist.filter = sprintf('%s\\.%04d',upper(s.scannerName), s.structuralSeries); % filter files based on scannername and series number

spm_jobman('run', matlabbatch);

fprintf('conversion of structural data done in:');
toc(t)

end