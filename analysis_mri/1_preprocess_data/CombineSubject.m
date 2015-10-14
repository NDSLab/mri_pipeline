function CombineSubject(SUBJECT_NUMBER, SESSION_NUMBER)
% -------------------------------------------------------------------------
% Function: Combine Subject (SUBJECT_NUMBER,SESSION_NUMBER)
% 
% This function converts the raw DICOMs into nifti images, runs a simple
% spike-detection script (no spike removal!, just detection), and combines
% the multi-echoes images. 
% 
% The output are 'crf*.nii' images, which can be used to preprocesses as
% usual. 
% 
% Note that images have to be realigned for combining, so that step
% is no longer necessary. Realignment is performed using SPM12. 
% -------------------------------------------------------------------------
%
% 
% Input:
%  SUBJECT_NUMBER       ... integer, indicating subject number
%  SESSION_NUMBER       ... [optional] integer,indicating session number,
%                           if not provided, will be set to 1.
% 
% Usage: 
%   This is meant to be used via:
%     qsubfeval(@CombineSubject, s, 'memreq', cfg.memreq,...
%               'timreq', cfg.timreq);
%   OR:
%     batch_CombineSubject.m
%   OR: in an interactive matlab session:
%     CombineSubject(13);
% 
% -------------------------------------------------------------------------


% set default session number
if ~exist('SESSION_NUMBER','var')
    SESSION_NUMBER=1;
end


% log everything written to console
if ~exist('logs','dir'); mkdir('logs'); end
diary(['logs/combineSubject_s' num2str(SUBJECT_NUMBER) '.log'])
fprintf('========================================================================\n');


% add path '../utils' to matlab PATH, without having relative path
% note: if this is not done, mfilename will return relative path, which
% might mess up other script, notably the GetSubjectProperties.m
[currentPath, ~, ~] = fileparts(mfilename('fullpath'));
pathParts = strsplit(currentPath,filesep);
addpath(sprintf('/%s/utils',fullfile(pathParts{1:(end-1)})));

% load SPM12, incl. defaults
LoadSPM;

try
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
    [workingDir, usingCustomWorkingDir] = SetUpWorkingDir(s.dataPreprocessedPath);
    
    %- set settings for combining
    config.runSeries                    = s.runSeries;
    config.nEchoes                      = s.nEchoes;
    config.dataDir                      = s.dataRawPath;
    config.workingDir                   = workingDir;
    config.outputDir                    = s.dataPreprocessedPath;
    config.nWeightingVolumes            = s.nWeightVolumes;
    config.keepIntermediaryFiles        = s.deleteUncombinedData;
    config.saveWeightsToFile            = true;
    config.filenameWeights              = 'CombiningWeights';
    config.arrangeRunsIntoSubfolders    = true;
    config.addRunAsSuffix               = true;
    
    %- set spike-script settings
    %- there are multiple ways of detecting spikes. See function
    % ../utils/CheckForSpikes.m to see what they do in detail and what
    % configurations are possible
    config.configSpike.spikeThreshold           = 0.3;                  % fractional deviation of slice mean that qualifies as a 'spike' 0.1 = 10%
    config.configSpike.maskSize                 = 8;                    % number of voxels - will be used to pick (n x n) square in each corner of a slice, for masking
    config.configSpike.detectionMethod          = 'timecourseAverage';  % Select spikes based on 'timecourseAverage' or 'previousVolume; cf ../utils/DetectSpikes.m for details
    config.configSpike.outputDir                = s.folderDataQualityChecks; % folder where output files (timeseries plots and copies of spike-containing volumes will be written
    config.configSpike.filenamePlotBase         = 'sliceAverages';       % this will be used to create plot filenames, by appending run and echo number
    
    %- run Combining steps
    RunCombining(config);
    
    %- remove working dir if we needed to create it within matlab
    if usingCustomWorkingDir
        % clean up working dir created by this script
        fprintf('removing working directory %s\n',workingDir);
        rmdir(workingDir,'s')
    end
   
    fprintf('\nsuccessfully combined data\n');
    
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
