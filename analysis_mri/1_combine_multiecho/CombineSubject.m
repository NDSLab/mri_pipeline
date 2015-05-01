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
    
    % log everything written to console
    diary(['combineSubject_s' num2str(subjectNumber) '.log'])
    fprintf('%s - Starting combination script for subject %i\n',datestr(now),subjectNumber);
    
    addpath('/home/common/matlab/spm12');
    addpath('../utils'); 
    
    % set default session number
	if ~exist('sessionNumber','var')
   		sessionNumber=1;
	end

    % get subject specific folders, project number, etc.
    % load meta-data, defined in /data_raw/scan_metadata.m
    % assuming location on M-drive is like:
    % /home/decision/petvav/projects/3014030.01/3014030.01_petvav_001_001/data_raw/scan_metadata.m
        addpath('../utils');
    s=GetSubjectProperties(subjectNumber,sessionNumber);

	s.subjectSettingsFile = [s.dataRawPath '/scans_metadata.m'];
       
    % print some info (for log-file)
    fprintf('\n===============================\n');
    fprintf('Subject %d - Session %d:\n',subjectNumber,sessionNumber);
    fprintf('Series corresponding to first echo of each run: %s\n', mat2str(s.runSeries));
    fprintf('Number of Echoes: %s\n', mat2str(s.nEchoes));
    fprintf('Number of Prescan-Volumes: %d\n', s.nWeightVolumes);
    
    % define a working directory
    j = get_jobinfo();
    if j.workingDir 
        % use the working directory already created
        workingDir = j.workingDir;
    else 
        % try to create folder '/data/$user/$jobinfo'
        try 
            workingDir = sprintf('/data/%s/%s',j.username,j.jobid); 
            mkdir(workingDir)
            assert(exist(workingDir,'dir')==7,'Error: workingPath not created');
            usingCustomWorkingDir = true;
        catch 
            % if we cannot create '/data/$user/$jobinfo', then use
            % outputDir as working directory
            warning('WARNING: DATA MIGHT BE OVERWRITTEN. No working directory found and could not create one. Going to use the output path.', s.dataCombinedPath);
            workingDir = s.dataCombinedPath;
        end
    end
    % assert we can read/write to working dir
    [status, m, mId]=mkdir(workingDir); % use output to suppress warning that folder exists - it should, but just in case...
    assert(exist(workingDir,'dir')==7,'Error: workingPath not created');
    [status,workingDirAccess] = fileattrib(workingDir);
    assert(workingDirAccess.UserRead==1,'No reading rights for working directory "%s"',workingDir);
    assert(workingDirAccess.UserWrite==1,'No writing rights for working directory "%s"',workingDir);
    fprintf('using working directory "%s"\n', workingDir); 
    
    % run Wrapper for combiner
    wrapper = CombineWrapper(   'runSeries',s.runSeries,...
                                'nEchoes',s.nEchoes,...
                                'dataDir',s.dataRawPath,...
                                'outputDir',s.dataCombinedPath,...
                                'workingDir',workingDir,...
                                'keepIntermediaryFiles',~s.deleteUncombinedData...
                                );
    wrapper.DoMagic();
    
    if usingCustomWorkingDir
        % clean up working dir created by this script
        fprintf('removing working directory %s\n',workingDir);
        rmdir(workingDir,'s')
    end
    
    fprintf('\nsuccessfully combined data\n');
    fprintf('\n===============================\n');
    diary off
end
