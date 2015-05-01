function  out  = GetSubjectProperties(subjectNumber,sessionNumber)
%GETSUBJECTPROPERTIES returns a structure containing some useful
%metainformation based on assumed folder structure of project

% get all path-related defaults
[path_str,filename, extension] = fileparts(mfilename('fullpath'));
pathParts = strsplit(path_str,'/');
out.projectFolder = sprintf('%s/',pathParts{1:end-2});  % has trailing '/'
out.projectNumber = pathParts{end-2};
[~, userName] = system('whoami'); out.userName=userName(1:end-1); % system('whoami') contains trailing \n

out.subjectFolder=sprintf('%s%s_%s_%03d_%03d', out.projectFolder, out.projectNumber,out.userName,subjectNumber,sessionNumber);
out.dataRawPath=sprintf('%s/data_raw',out.subjectFolder);
out.dataCombinedPath=sprintf('%s/data_combined',out.subjectFolder); %combined data folder for all subjects - here, the combined data will be saved
out.subjectSettingsFile = [out.dataRawPath '/scans_metadata.m'];

% load subject scan metadata
% exit(..,'file') returns 2, if file exists
assert(exist(out.subjectSettingsFile,'file')==2, 'Error loading subject-specific settings file. File "%s" not found',out.subjectSettingsFile);
run(out.subjectSettingsFile);

% this should have created the following variables:
out.nEchoes = nEchoes;
out.nWeightVolumes = nWeightVolumes;
out.runSeries = runSeries;
out.structuralSeries = structuralSeries;
out.scannerName = scannerName;
out.deleteUncombinedData = deleteUncombinedData;
out.localizerSeries = localizerSeries;
out.prepscans = prepscans;
out.prescanSeries=prescanSeries;

end

