function listDicomNames = get_dicom_names(seriesNumber, folderPath)
% takes a series number and outputs all DICOM images - for all echoes!

% grab all images
allFiles = dir([folderPath '/*.IMA']);
% use first DICOM to extract string-before-echo-number
firstDicomInfo = dicominfo([folderPath '/' allFiles(1).name]);
expDate = firstDicomInfo.InstanceCreationDate;
expDate = [expDate(1:4) '.' expDate(5:6) '.' expDate(7:8)];
stringBeforeEchoNumber = allFiles(3).name(strfind(allFiles(3).name,expDate)-16:strfind(allFiles(3).name,expDate)-12); % e.g. 'SKYRA'

% based on that info, select all DICOMs 
filesTemp = dir([folderPath '/*' stringBeforeEchoNumber '.' sprintf('%.4d', seriesNumber) '*.IMA']);
fileNames = char(zeros(length(filesTemp),length(filesTemp(1).name)+2));
for i=1:size(fileNames ,1)
    fileNames (i,1:length(filesTemp(i).name)) = filesTemp(i).name;
end
a = repmat([folderPath, '/'], size(fileNames,1),1);
listDicomNames = cat(2, a , fileNames);

end