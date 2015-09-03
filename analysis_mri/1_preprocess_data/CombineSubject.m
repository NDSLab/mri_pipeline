% ---------------------------------------------------------------
% Function: [outputs] = Combine Subject (SUBJECT_NUMBER,SESSION_NUMBER)
% ---------------------------------------------------------------
%
% Assuming a certain folder structure, this function automatically
% parses the information needed to run the combine scripts for the
% subject specified by a number.
%
% This is meant to be used via:
% qsubfeval(@CombineSubject, s, 'memreq', cfg.memreq, 'timreq', cfg.timreq);
% OR:
% batch_CombineSubject.m
% 
% ---------------------------------------------------------------
function CombineSubject(SUBJECT_NUMBER, SESSION_NUMBER)
% assuming location on M-drive is like:
% /home/decision/petvav/projects/3014030.01/analysis_mri/1_combine/CombineSubject.m
% we can use this to define some variables:

% set default session number
if ~exist('SESSION_NUMBER','var')
    SESSION_NUMBER=1;
end


% log everything written to console
if ~exist('logs','dir'); mkdir('logs'); end
diary(['logs/combineSubject_s' num2str(SUBJECT_NUMBER) '.log'])

% add path '../utils' to matlab PATH, without having relative path
% note: if this is not done, mfilename will return relative path, which
% might mess up other script, notably the GetSubjectProperties.m
[currentPath, ~, ~] = fileparts(mfilename('fullpath'));
pathParts = strsplit(currentPath,filesep);
addpath(sprintf('/%s/utils',fullfile(pathParts{1:(end-1)})));

% load SPM12, incl. defaults
LoadSPM;

try
    
tic;

    % ge% load subject specific details
    s = GetSubjectProperties(SUBJECT_NUMBER, SESSION_NUMBER);
    
    % print some info (for log-file)
    fprintf('%s - Starting combination script for subject %i\n',datestr(now),SUBJECT_NUMBER);
    fprintf('\n===============================\n');
    fprintf('Subject %d - Session %d:\n',SUBJECT_NUMBER,SESSION_NUMBER);
    fprintf('Series corresponding to first echo of each run: %s\n', mat2str(s.runSeries));
    fprintf('Number of Echoes: %s\n', mat2str(s.nEchoes));
    fprintf('Number of Prescan-Volumes: %d\n', s.nWeightVolumes);
    
    % use outputDir, in case no other working dir available. This might
    % lead to quota issues, though...
    [workingDir, usingCustomWorkingDir] = SetUpWorkingDir(s.dataCombinedPath);
    
    %- set settings for combining
    config.runSeries                    = s.runSeries;
    config.nEchoes                      = s.nEchoes;
    config.dataDir                      = s.dataRawPath;
    config.workingDir                   = workingDir;
    config.outputDir                    = s.dataCombinedPath;
    config.nWeightingVolumes            = 30;
    config.keepIntermediaryFiles        = ~s.deleteUncombinedData;
    config.saveWeightsToFile            = true;
    config.filenameWeights              = 'CombiningWeights';
    config.arrangeRunsIntoSubfolders    = true;
    config.addRunAsSuffix               = true;
        
    %- run Combining steps
    RunCombining(config);
    
    %- remove working dir if we needed to create it within matlab
    if usingCustomWorkingDir
        % clean up working dir created by this script
        fprintf('removing working directory %s\n',workingDir);
        rmdir(workingDir,'s')
    end
    
    
    
    fprintf('\nsuccessfully combined data\n');
    toc
    fprintf('\n===============================\n');
    
catch err
    
    fprintf('ERROR: could not preprocess subject %i\n',SUBJECT_NUMBER);
    fprintf('ERROR: %s\n',err.message);
    timestamp = datestr(now,30);
    error_filename = ['error' timestamp];
    save(error_filename,'err');
end

diary off
end
