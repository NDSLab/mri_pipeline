% ---------------------------------------------------------------
% Function: [outputs] = Combine Subject (subjectNumber)
% ---------------------------------------------------------------
% 
% Assuming a certain folder structure, this function automatically
% parses the information needed to run the combine scripts for the
% subject specified by a number.
% 
% This is meant to be used via: 
% qsubfeval(@CombineSubject, s, 'memreq', cfg.memreq, 'timreq', cfg.timreq);
% ---------------------------------------------------------------
function [outputs] = CombineSubject(subjectNumber, sessionNumber)
	% assuming location on M-drive is like:
	% /home/decision/petvav/projects/3014030.01/analysis_mri/1_combine/CombineSubject.m
	% we can use this to define some variables:

    addpath('~/repos/spm12');

    % set default session number
	if ~exist('sessionNumber','var')
   		sessionNumber=1;
	end

    % get all path-related defaults
	[path_str,filename, extension] = fileparts(mfilename('fullpath'));
    pathParts = strsplit(path_str,'/');
    projectFolder = sprintf('%s/',pathParts{1:end-2});  % has trailing '/'
    projectNumber = pathParts{end-2};
    [~, userName] = system('whoami'); userName=userName(1:end-1) % system('whoami') contains trailing \n
    
    subjectFolder=[projectFolder projectNumber '_' userName '_' num2str(subjectNumber,'%03d') '_' num2str(sessionNumber,'%03d') '/'];
    dataRawPath=[subjectFolder 'data_raw'];
    combinedData=[subjectFolder 'data_combined']; %combined data folder for all subjects - here, the combined data will be saved

	% load meta-data, defined in /data_raw/scan_metadata.m
    % assuming location on M-drive is like:
    % /home/decision/petvav/projects/3014030.01/3014030.01_petvav_001_001/data_raw/scan_metadata.m
    subjectSettingsFile = [dataRawPath '/scans_metadata.m'];
    % exit(..,'file') returns 2, if file exists
    assert(exist(subjectSettingsFile,'file')==2, 'Error loading subject-specific settings file. File "%s" not found',subjectSettingsFile);
    run(subjectSettingsFile);

    % define a working directory
    workingDir = sprintf('/data/%s/%s/subj%03dsession%03d/combining',userName,projectNumber,subjectNumber,sessionNumber);
    mkdir(workingDir); % be sure to create folder
    % assert we can read/write to working dir
    workingDirAccess = fileattrib(workingDir);
    assert(workingDirAccess.UserRead==1,'No reading rights for working directory "%s"');
    assert(workingDirAccess.UserWrite==1,'No writing rights for working directory "%s"');
    % assert workingDir is empty; dir(folder_path) returns '.' and '..'
    assert(length(dir(workingDir))==2,'working directory is not empty -- "%s"')
    
	% print some info (for log-file)
    fprintf('Structural File Series: %s\n', mat2str(structuralSeries));
    fprintf('Localizer File Series: %s\n', mat2str(localizerSeries));
    fprintf('Series corresponding to first echo of each run: %s\n', mat2str(runSeries));
    fprintf('Number of Echoes: %s\n', mat2str(nEchoes));
    fprintf('Number of Prescan-Volumes: %d\n', nWeightVolumes);
                
    % run Wrapper for combiner
    wrapper = CombineWrapper(   'runSeries',runSeries,...
                                'nEchoes',nEchoes,...
                                'dataDir',dataRawPath,...
                                'outputDir',combinedData,...
                                'workingDir',workingDir);
    wrapper.DoMagic();

    % remove working directory and its content
    rmdir(workingDir,'s');

end
