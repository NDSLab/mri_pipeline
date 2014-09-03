% Series of Structural files
% The series number of your structural scans (see Print List). Look for the
% series number of t1_mprage_sag (192 scans).
structuralSeries=[7]; 

% Series of Localizer files
% The series number of your localizer scans: localizer, t2_haste and Scout
% scans in the Print list.
localizerSeries=[1 3 4];

% Series corresponding to first echo of each run
% The series numbers of where each run starts. This should be consistent
% with expArray
runSeries=[10 15 20];

% Number of Echoes
% nEchoes can be a single integer - if you use for all runs the same number
% of echoes; alternatively, nEchoes can be an array of the same length as
% runSeries, with each one indicating that run's number of echoes
% Examples:
%   case 1: 
%           same number of echoes for all runs:
%           nEchoes=4;
%   case 2:
%           one run (e.g. resting state) as 5 echoes, and 3 runs have the
%           same  (e.g. the task runs). With runSeries=[10 16 20 23], where
%           series nr 10 has 5 echoes and 16-23 have 4 echoes%       
%           nEchoes=[5 4 4 4]; 
nEchoes=4; 

% Delete subject data in uncombined data folder after combination 
deleteUncombinedData=1;

% Note:
% we assume you'll analyze (first..) your sessions individually
% Even in a multi-session studies, you're data is assumed to be stored in 
% session-specific folders (e.g. 3014030.01_petvav_001_001 and 
% 3014030.01_petvav_001_002 for subject 1, sessions 1 and 2). 

% The following is used to identify all dicom files, coming from a scanner
scannerName={'Skyra','Avanto','Trio'}; % these are valid options
scannerName = scannerName{1}; % pick the one applying by setting the index

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% BELOW: Only needs editing if not following group-defaults

% Number of Volumes
nWeightVolumes=30;



% Number of prepscans for each run, files will be moved to prepscan folders
% These scans will not be used in your analysis, but for combining
% multi-echo data. The series numbers of where you started with 30 pulses
% (the prescans). We decided that we need 30 pulses before every run.
prepscans=repmat(30,1:length(runSeries));

% Series corresponding to first echo of each prescan 
% The series numbers of where you started with 30 pulses (the prescans). We
% decided that we need 30 pulses before every run, so prescanSeries should
% contain the same numbers as runSeries.
prescanSeries=runSeries;