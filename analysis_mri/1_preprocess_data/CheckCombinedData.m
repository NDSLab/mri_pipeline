function CheckCombinedData(SUBJECT_NUMBER, SESSION_NUMBER)
%
% Checks combined  fMRI data per subject. This creates some basic plots of
% the signal.
%
% Input:
%  SUBJECT_NUMBER       ... integer, indicating subject number
%  SESSION_NUMBER       ... [optional] integer,indicating session number,
%                           if not provided, will be set to 1.
% 
%--------------------------------------------------------------------------

diary(['logs/data_quality_check' num2str(SUBJECT_NUMBER) '.log'])

% add path '../utils' to matlab PATH, without having relative path
% note: if this is not done, mfilename will return relative path, which
% might mess up other script, notably the GetSubjectProperties.m
[currentPath, ~, ~] = fileparts(mfilename('fullpath'));
pathParts = strsplit(currentPath,filesep);
addpath(sprintf('/%s/utils',fullfile(pathParts{1:(end-1)})));

% load SPM12, incl. defaults
LoadSPM;

% set default: session_number == 1
if ~exist('SESSION_NUMBER','var')
    SESSION_NUMBER=1;
end

fprintf('QUALITY CHECKS: starting checking subject %i (session %i) data\n', SUBJECT_NUMBER, SESSION_NUMBER)

try
    
    subjectParameter = GetSubjectProperties(SUBJECT_NUMBER,SESSION_NUMBER);
    nRuns = length(subjectParameter.runSeries);
    
    % define where to put output files
    folderOutput = fullfile(subjectParameter.subjectFolder, 'data_quality_checks');
    if ~exist(folderOutput, 'dir' ); mkdir(folderOutput); end % ensure the folder exists
    
    for iRun=nRuns:-1:1
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
        
        %- Create histrogram of data
        %-----------------------------------
        % create histogram of data
        % Making a histogram of the data
        nbins = 128;
        titleString = sprintf('Histogram of subject %i - session %i - run %i', SUBJECT_NUMBER, SESSION_NUMBER,iRun);
        filenameHistogram = fullfile(folderOutput, sprintf('Histogram_%03d_%03d_run%i.png', SUBJECT_NUMBER, SESSION_NUMBER,iRun) );
        
        %- run function
        CreateHistogram(data,nbins,titleString,filenameHistogram)
        
        %- create signal intensity curves
        % create intensity=f(time) plots
        titleString = sprintf('Check: signal - subject %i (session %i) - run %i',SUBJECT_NUMBER, SESSION_NUMBER,iRun);
        filenameSignal = fullfile(folderOutput, sprintf('SignalCheck_%03d_%03d_run%i.png', SUBJECT_NUMBER,SESSION_NUMBER,iRun));
        %- run function
        %-----------------
        CreateMeanCurvePlot(data,titleString, filenameSignal);
    end
        
    % and create movement parameter plots
    CheckMovementParatemeters(SUBJECT_NUMBER,SESSION_NUMBER);
    
catch err
    fprintf('ERROR: could not preprocess subject %i\n',SUBJECT_NUMBER);
    fprintf('ERROR: %s\n',err.message);
    timestamp = datestr(now,30);
    error_filename = ['error' timestamp];
    save(error_filename,'err');
end

fprintf('========================================================================\n');
fprintf('========================================================================\n');
diary off
end
    
    
    