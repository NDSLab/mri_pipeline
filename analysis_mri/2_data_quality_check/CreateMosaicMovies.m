function CreateMosaicMovies(SUBJECT_NUMBER, SESSION_NUMBER)
%
% create "mosaic" Movies of combined fMRI data - just like the view while
% scanning. 
%
% Movie
%
% data should be nested as:
%       /home/group/DCCN-user-id/~/mri_pipeline-master/mri_pipeline-master_DCCN-user-id_SUBJ_NR_SESSION_NR/
%       eg.
%       /home/decision/inghui/~/mri_pipeline-master/mri_pipeline-master_inghui_101_001/
%
% Input:
%       SUBJ_NR            ...unique participant number
%       SESSION_NR         ...
%
diary(['logs/data_quality_check' num2str(SUBJECT_NUMBER) '.log'])

% you can comment this assertion out, if you change the movie codec to
% 'Uncompressed AVI' or 'Motion JPEG AVI' below
assert(ispc,'You need to run this script from a Windows machine');

% add path '../utils' to matlab PATH, without having relative path
% note: if this is not done, mfilename will return relative path, which
% might mess up other script, notably the GetSubjectProperties.m
[currentPath, ~, ~] = fileparts(mfilename('fullpath'));
pathParts = strsplit(currentPath,filesep);
addpath(sprintf('%s/utils',fullfile(pathParts{1:(end-1)})));

% load SPM12, incl. defaults
LoadSPM;

% set default: session_number == 1
if ~exist('SESSION_NUMBER','var')
    SESSION_NUMBER=1;
end

% -------------------------------------------------------------------------
fprintf('QUALITY CHECKS: starting checking subject %i (session %i) data\n', SUBJECT_NUMBER, SESSION_NUMBER)

subjectParameter = GetSubjectProperties(SUBJECT_NUMBER,SESSION_NUMBER);
nRuns = length(subjectParameter.runSeries);

% define where to put output files
folderOutput = fullfile(subjectParameter.subjectFolder, 'data_quality_checks');
if ~exist(folderOutput, 'dir' ); mkdir(folderOutput); end % ensure the folder exists

try
    
    % handle each run separately;
    for iRun=nRuns:-1:1
        %%%% step 1  - load image data into 4d array
        %- set settings for loading image data
        %---------------------------------------
        folderImages = sprintf('%s/run%i',subjectParameter.dataPreprocessedPath,iRun);
        % file filter used by SPM - modify if you want to create videos from other images
        fileFilter = '^crf\S*nii$'; % use ^crf to get combined, but otherwise untouched images (ie not 'preprocessed')
        % whether SPM should decend into subfolders of 'folderImages' when looking for files
        decendIntoSubfolders = false;
        
        %- run function
        %-----------------
        [data, ~] = LoadImageData(folderImages, fileFilter, decendIntoSubfolders);
        
        %%%% step 2  - create mosaic videos
        %- set movie-script settings
        %--------------------------------
        % folder where movies will be saved
        configMovie.folderOutput = folderOutput;
        % the following settings should note be changed unless you want to tweak the movie properties
        % Frames per second.
        configMovie.framesPerSecond = 6;
        % define a movie using 'brightness' clims definition
        configMovie.clims{1}.type = 'brightness';
        configMovie.clims{1}.value = 0.97; % Brightness value of movie. A value between -1 (very dark) and 1 (very bright) with 0 to leave the image as it is. Set to 0.97 to see the noise clearly.
        configMovie.movieFilenames{1} =sprintf('CheckMosaicMovie_default_%03d_%03d_run%i',SUBJECT_NUMBER,SESSION_NUMBER,iRun);
        % define movie using percentiles below/above which to clip:
        configMovie.clims{2}.type = 'percentile';
        configMovie.clims{2}.value(1) = 0.002; % percentile below which to clip to black
        configMovie.clims{2}.value(2) = 0.60; % percentile above which to clip to white
        configMovie.movieFilenames{2} = sprintf('CheckMosaicMovie_contrast_%03d_%03d_run%i',SUBJECT_NUMBER,SESSION_NUMBER,iRun);
        % which compression type VideoWriter will use
        configMovie.compressionType = 'MPEG-4';
        
        %- run function
        %-----------------
        CreateMovie(configMovie, data);
    end
catch err
    workspaceFilename = sprintf('workspaceMovies_%03.0f_%03.0f',SUBJECT_NUMBER,SESSION_NUMBER);
    save(workspaceFilename)
    rethrow(err);
end
diary off
end

