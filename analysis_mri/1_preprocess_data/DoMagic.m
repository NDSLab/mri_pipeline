function DoMagic( SUBJECT_NUMBER, SESSION_NUMBER, WINDOWS_PC_ID )
% -------------------------------------------------------------------------
% function DoMagic( SUBJECT_NUMBER, SESSION_NUMBER, WINDOWS_PC_ID ) 
% 
% Preprocess and check quality of single subject, incl. getting and
% removing raw data from a windows PC D-drive
% 
% -------------------------------------------------------------------------
% Input:
%  SUBJECT_NUMBER       ... integer, indicating subject number
%  SESSION_NUMBER       ... [optional] integer,indicating session number,
%                           if not provided, will be set to 1.
%  WINDOWS_PC_ID        ... string, indicating the windows PC name, for
%                           example 'dccn677'
% 
% Assuming D-drive has the same folder structure as the M-drive (e.g.
% D:\projects\3014030.01 and M:\projects\3014030.01), this script will
% automatically copy the raw images onto the M-drive, preprocess them, run
% the data quality checks and then remove the raw data again from the
% M-drive. 
% 
% -------------------------------------------------------------------------

% set default session number
if ~exist('SESSION_NUMBER','var')
    SESSION_NUMBER=1;
end

% set default session number
if ~exist('WINDOWS_PC_ID','var')
    WINDOWS_PC_ID='dccn677';
end

% add path '../utils' to matlab PATH, without having relative path
% note: if this is not done, mfilename will return relative path, which
% might mess up other script, notably the GetSubjectProperties.m
[currentPath, ~, ~] = fileparts(mfilename('fullpath'));
pathParts = strsplit(currentPath,filesep);
addpath(sprintf('/%s/utils',fullfile(pathParts{1:(end-1)})));

LoadSPM;

%- copy raw data onto M-drive
fprintf('\ncopying files to M-drive\n');
CopyRawDataFromDToMDrive(SUBJECT_NUMBER, SESSION_NUMBER, WINDOWS_PC_ID);

%- preprocess everything
fprintf('\ncombining subject\n');
CombineSubject(SUBJECT_NUMBER,SESSION_NUMBER);

fprintf('\npreprocessing subject\n');
PreprocessSubject(SUBJECT_NUMBER,SESSION_NUMBER);

%- run data quality checks
% TODO: Add refactored data quality checks

fprintf('\nremoving data_raw\n');
%- remove raw data again from M-drive
RemoveRawDataFromMDrive(SUBJECT_NUMBER,SESSION_NUMBER);

%- remove combined, unpreprocessed data
% fprintf('\nremoving combined, but not preprocessed images.\n');
% RemoveCombinedData(SUBJECT_NUMBER, SESSION_NUMBER);

fprintf('\nDoMagic is done with subject %i (session %i)\n', SUBJECT_NUMBER, SESSION_NUMBER);



end

