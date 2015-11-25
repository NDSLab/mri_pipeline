% The following is used to identify all dicom files, coming from a scanner
scannerName={'Skyra','Avanto','Trio'}; % these are valid options
scannerName = scannerName{1}; % pick the one applying by setting the index

% Series Number of Structural files
% The series number of your structural scans (see Print List). Look for the
% series number of t1_mprage_sag (typically 192 scans).
structuralSeries=[7]; 

% Series Number corresponding to first echo of each run
% The series numbers of where each run starts.
runSeries=[10 15 20];

% Number of Echoes 
% Integer. in your functional images - we assume that all functional runs are from the same sequence
% integer 
nEchoes=4; 



% Delete uncombined nifti data folder after combination 
% if "true", this will delete the niftis corresponding to the raw data (raw
% DICOMs are not affected by this setting), which are used for combining.
% This is used in CombineSubject.m
deleteUncombinedData = true;

% Delete or keep intermediary files created during SPM preprocessing (e.g.
% slice-timing, normalization, etc.)
% This is used in PreprocessSubject.m
keepPreprocessingIntermediaryFiles = false;

% How many images do you have per run - for one Echo? 
% If present these numbers will be used to check whether you have all the 
% expected images in your folders. 
% See analysis_mri/2_data_quality_check/CheckNumberImages.m
nVolumes = [383 382 410];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% BELOW: Only needs editing if not following group-defaults

% Number of Volumes used in each run calculate the combining weights
nWeightVolumes=30;