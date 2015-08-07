function DoMagic( SUBJECT_NUMBER, SESSION_NUMBER)
% -------------------------------------------------------------------------
% function DoMagic( SUBJECT_NUMBER, SESSION_NUMBER ) 
% 
% This function goes over all the steps required to go from raw DICOMs to
% preprocessed images, including some simple data quality checks.
% After uncommenting some code, it can also clean up intermediary files.
% 
% The final output will be 'swacrf*.nii' images which you can use for your
% first-level anaylsis.
% 
% -------------------------------------------------------------------------
% Input:
%  SUBJECT_NUMBER       ... integer, indicating subject number
%  SESSION_NUMBER       ... [optional] integer,indicating session number,
%                           if not provided, will be set to 1.
% 
% Note: This function assumes your data are organized in a certain way.
% Please check the Getting-Started page in the documentation what exactly
% you have to do.
% 
% Note: Per default, no data will be removed from your drive (e.g. raw
% data). However, there are functions to do so in place. Uncomment the
% marked sections to enable them. Otherwise, you can always run them
% manually afterwards.
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

LoadSPM;

%- Combine multi-echo data
fprintf('\ncombining subject\n');
CombineSubject(SUBJECT_NUMBER,SESSION_NUMBER);

%- Run data quality checks on combined data
fprintf('\ncombining subject\n');
CheckCombinedData(SUBJECT_NUMBER,SESSION_NUMBER);

%- SPM-preprocess data
fprintf('\npreprocessing subject\n');
PreprocessSubject(SUBJECT_NUMBER,SESSION_NUMBER);

%% UNCOMMENT TO REMOVE RAW DATA AUTOMAGICALLY
% fprintf('\nremoving data_raw\n');
% %- remove raw data again from M-drive
% RemoveRawDataFromMDrive(SUBJECT_NUMBER,SESSION_NUMBER);

%% UNCOMMENT TO REMOVE COMBINED, BUT NOT FULLY PREPROCESSED, FILES AUTOMAGICALLY
% % if you don't want to create videos of your combined, but otherwise not
% % preprocessed data, you can enable this section here. If you DO want
% % those, you should first run CreateMovies and then run manually the
% % RemoveCombinedData function.
% %- remove combined, unpreprocessed data
% fprintf('\nremoving combined, but not preprocessed images.\n');
% RemoveCombinedData(SUBJECT_NUMBER, SESSION_NUMBER);

fprintf('\nDoMagic is done with subject %i (session %i)\n', SUBJECT_NUMBER, SESSION_NUMBER);



end

