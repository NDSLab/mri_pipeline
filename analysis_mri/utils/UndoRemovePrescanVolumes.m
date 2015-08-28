function UndoRemovePrescanVolumes( SUBJECT_NUMBER, SESSION_NUMBER)
% =========================================================================
%                             WARNING:
% 1) Make sure that the User Settings are the same for Do and Undo
% functions!
% 2) This function assumes runs are sorted into different subfolders, incl.
% the motion parameters!
%
%                           USER BEWARE !
% =========================================================================
% UndoRemovePrescanVolumes undoes what steps DoRemovePrescanVolumes.m took.
%
% This convenience function can be used to put the prescans of each run
% back into the main folder of each run.
% 
% This script assumes each run is in it's separate folder.
% 

% -------------------------------------------------------------------------
% USER SETTINGS:
% -------------------------------------------------------------------------
% Note: these should match the settings in 'DoRemovePrescanVolumes.m'

ZIP_PRESCANS = true;
FOLDER_NAME_PRESCANS = 'prescans';
FILENAME_MOTION_PARAMETERS = 'rp_prescans.txt';

% -------------------------------------------------------------------------

% set default session number
if ~exist('SESSION_NUMBER','var')
    SESSION_NUMBER=1;
end

% add path '../utils' to matlab PATH, without having relative path
% note: if this is not done, mfilename will return relative path, which
% might mess up other script, notably the GetSubjectProperties.m
[currentPath, ~, ~] = fileparts(mfilename('fullpath'));
pathParts = strsplit(currentPath,filesep);
addpath(sprintf('/%s/utils',fullfile(pathParts{1:(end-1)})));


oldFolder = pwd;

s = GetSubjectProperties(SUBJECT_NUMBER, SESSION_NUMBER);
nRuns = length(s.runSeries);

for iRun = 1:nRuns
    % go to folder with data preprocessed images, of a run
    folderData = sprintf('%s/run%i',s.dataCombinedPath, iRun);
    cd(folderData);

    % unzip archive
    if ZIP_PRESCANS
        unixCommand = sprintf('tar -xf %s.tar.gz && rm %s.tar.gz', FOLDER_NAME_PRESCANS, FOLDER_NAME_PRESCANS);
%         unixCommand = sprintf('tar -xf %s.tar.gz', FOLDER_NAME_PRESCANS);
        unix(unixCommand);
    end
    
    % move all *.nii files back to the run
    filePrefixes = {'swacrf', 'wacrf', 'acrf', 'crf'};
    for i=1:numel(filePrefixes);
        filePrefix = filePrefixes{i};
        
        % first check that there are not already files in the prescans folder,
        % that match current file filter and number of prescans
        unixCommand = sprintf('find %s -maxdepth 1 -type f -name ''%s*.nii'' | xargs -r mv -v -t %s', FOLDER_NAME_PRESCANS, filePrefix,folderData);
        [~, cmdResult] = unix(unixCommand);
    end
    
    % combine rp_*.txt files of prescans and main volumes
    % first move prescan file into same folder
    unixCommand = sprintf('mv %s/%s %s',FOLDER_NAME_PRESCANS, FILENAME_MOTION_PARAMETERS, folderData);
    unix(unixCommand);
    % now simply append rp_f*.txt to prescans 
    unixCommand = sprintf('cat rp_f*.txt >> %s;', FILENAME_MOTION_PARAMETERS);
    unix(unixCommand);
    % rename combined file to rp_f*.txt file
    unixCommand = sprintf('find * -maxdepth 1 -type f -name ''rp_f*.txt'' | xargs mv -v %s', FILENAME_MOTION_PARAMETERS);
    [~,r]=unix(unixCommand);
    
    % remove prescans folder if emtpy
    % Note, rmdir will exit with error if folder not emtpy.
    unixCommand = sprintf('rmdir %s', FOLDER_NAME_PRESCANS);
    unix(unixCommand);
end  
    

cd(oldFolder);

end

