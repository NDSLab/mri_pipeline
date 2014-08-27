
function TE=RB_ME_PAID_Dicom2Nifti(directory, numberOfTE)
oldFolder = pwd;
% preallocate memory
TE = zeros(1,numberOfTE);

%% find the first echo %%
cd(directory);
allFiles = dir(directory);
firstFileDicom = dicominfo(allFiles(3).name);
expDate = firstFileDicom.InstanceCreationDate;
expDate = [expDate(1:4) '.' expDate(5:6) '.' expDate(7:8)];
firstEchoNumber = [ '0' allFiles(3).name(strfind(allFiles(3).name,expDate)-11:strfind(allFiles(3).name,expDate)-7)];
stringBeforeEchoNumber = allFiles(3).name(strfind(allFiles(3).name,expDate)-16:strfind(allFiles(3).name,expDate)-12);

%% Dicom2Nifti %%
filePerCycle = 50; % # of volumes to be converted in one for cycle, .._headers & .._convert functions seem to slow down with increasing number of inputs.
for k = 1:numberOfTE
    currentEchoNumber = ceil(str2num(firstEchoNumber)*10000 + (k-1));
    filesTemp = dir(['*' stringBeforeEchoNumber '.' sprintf('%.4d', currentEchoNumber) '.*']);
    files = char(zeros(length(filesTemp),length(filesTemp(1).name)+2));
    for i=1:size(files,1)
        files(i,1:length(filesTemp(i).name)) = filesTemp(i).name;
    end
    for i=1:ceil(size(files,1)/filePerCycle)
        if i==ceil(size(files,1)/filePerCycle)
            hdr = spm_dicom_headers(files((i-1)*filePerCycle+1:end,:));
            TE(k) = hdr{1}.EchoTime;
            spm_dicom_convert(hdr,'mosaic','flat','nii');
        else
            hdr = spm_dicom_headers(files((i-1)*filePerCycle+1:i*filePerCycle,:));
            TE(k) = hdr{1}.EchoTime;
            spm_dicom_convert(hdr,'mosaic','flat','nii');
        end
    end
end

% return to old folder
cd(oldFolder);