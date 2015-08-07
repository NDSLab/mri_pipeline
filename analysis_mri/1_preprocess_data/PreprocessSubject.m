function PreprocessSubject(SUBJECT_NUMBER, SESSION_NUMBER)

% set default session number
if ~exist('SESSION_NUMBER','var')
    SESSION_NUMBER=1;
end

if ~exist('logs','dir'); mkdir('logs'); end
diary(['logs/preprocessing_subject' num2str(SUBJECT_NUMBER) '.log'])
tic


% add path '../utils' to matlab PATH, without having relative path
% note: if this is not done, mfilename will return relative path, which
% might mess up other script, notably the GetSubjectProperties.m
[currentPath, ~, ~] = fileparts(mfilename('fullpath'));
pathParts = strsplit(currentPath,filesep);
addpath(sprintf('/%s/utils',fullfile(pathParts{1:(end-1)})));

% prepare spm jobman
LoadSPM();
spm_jobman('initcfg');


% try
    
    tic
    
    % load subject specific details
    s = GetSubjectProperties(SUBJECT_NUMBER, SESSION_NUMBER);
    KEEP_INTERMEDIARY_FILES = s.keepPreprocessingIntermediaryFiles;

    
    % set up working directory
    % ---------------------------------------------------------------------
    [workingDir, usingCustomWorkingDir] = SetUpWorkingDir(s.dataCombinedPath);
    
    
    %- Convert Structuctural
    % ---------------------------------------------------------------------
    % set settings for converting structural images
    % load matlabbatch variable
    clear matlabbatch; % to be sure to start with a fresh job description
    run('spmbatch_structural.m');
    
    % overwrite subject-specific job-stuff
    matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_named_dir.dirs = {{s.dataRawPath}};
    matlabbatch{2}.cfg_basicio.file_dir.file_ops.file_fplist.filter = sprintf('%s\\.%04d',upper(s.scannerName), s.structuralSeries); % filter files based on scannername and series number
    matlabbatch{3}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.name = s.dataStructuralPath; % this is an absolute path, so the parent is '/'
    matlabbatch{3}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.parent = {'/'};
    
    fileFilter = sprintf('%s/*%s.%04d*',s.dataRawPath, upper(s.scannerName),s.structuralSeries);
    %- assert raw data still present, otherwise skip this step
    if ~( exist(s.dataRawPath,'dir') && ~isempty(dir(fileFilter)) )
        fprintf('No structural DICOM files found. Skipping DICOM to Nifti conversion');
    else
        %- run SPM job
        fprintf('converting structural DICOMs to Nifti...\n');
        spm_jobman('run', matlabbatch);
        fprintf('converting structural DICOMs to Nifti - done\n');
    end
    
    toc
    
    %- copy structural and combined data to working dir
    % ---------------------------------------------------------------------
    % this step should make preprocessing with SPM a bit faster, since
    % we're not writing all intermediary steps to the m-drive, but the
    % working directory (which should be the mentat-node's local hard disk)
    
    % copy combined data folder to workingDirectory
    workingDirCombined = CopyCombinedDataForPreprocessing(s.dataCombinedPath, workingDir);
    
    % copy structural data to workingDirectory
    workingDirStructural = CopyStructuralDataForPreprocessing(s.dataStructuralPath, workingDir);
    
  
    fprintf('copied files to working dir')
    toc
    
    %- set settings for functional data preprocessing
    %--------------------------------------------------
    % load matlabbatch variable
    clear matlabbatch; % to be sure to start with a fresh job description
    run('spmbatch_preprocessing.m');
    
    % overwrite subject-specific variables
    matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_named_dir.dirs = {{workingDirStructural}}; % where structural nifti files are
    matlabbatch{2}.cfg_basicio.file_dir.dir_ops.cfg_named_dir.dirs = {{workingDirCombined}}; % where combined nifti files are
    
    %- run SPM job
    %-----------------
    fprintf('Preprocessing functional images... \n');
    spm_jobman('serial', matlabbatch);
    fprintf('Preprocessing functional images - done\n');
    toc
    
    % copy preprocessed files back onto M-drive
    %--------------------------------------------------
    CopyPreprocessedDataBackFromWorkingDir( workingDirStructural, s.dataStructuralPath, ...
                                            workingDirCombined, s.dataCombinedPath,...
                                            KEEP_INTERMEDIARY_FILES);
    
    toc
    
    % clean up working directory if it was created by matlab
    if usingCustomWorkingDir
        % clean up working dir created by this script
        fprintf('removing working directory %s\n',workingDir);
        rmdir(workingDir,'s')
    end
    
% catch err
%     
%     fprintf('ERROR: could not preprocess subject %i\n',SUBJECT_NUMBER);
%     fprintf('ERROR: %s\n',err.message);
%     timestamp = datestr(now,30);
%     error_filename = ['error' timestamp];
%     save(error_filename,'err','matlabbatch');
% end
toc
fprintf('finished proprocessing at %s\n', datestr(now));
diary off;

end

