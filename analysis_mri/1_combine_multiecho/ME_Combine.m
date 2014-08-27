function varargout = ME_Combine(prescanPath,sourcePath, targetPath, numberOfEchoes, numberOfWeightVolumes,filename_base)
%% Initialization %%
smoothingPrefix = 'r';

oldFolder=pwd;
addpath('/home/common/matlab/spm8');
addpath(pwd);
cd(sourcePath);

%% Display folders and variables
fprintf('Prescan folder:\n%s\n',prescanPath);
fprintf('Input folder:\n%s\n',sourcePath);
fprintf('Output folder:\n%s\n',targetPath);
fprintf('Echoes: %d\n', numberOfEchoes);
fprintf('Volumes: %d\n', numberOfWeightVolumes);

% ensure that prescans are present
if isempty(prescanPath)
    error('ME_Combine::Error: expecting path to scans for weight calculation ');
end

%% clear output folder %%
if exist([targetPath '/PAID_data']) == 7
    rmdir([targetPath '/PAID_data'],'s');
end
if exist([targetPath '/converted_Weight_Volumes']) == 7
    rmdir([targetPath '/converted_Weight_Volumes'],'s');
end
if exist([targetPath '/converted_Volumes']) == 7
    rmdir([targetPath '/converted_Volumes'],'s');
end
delete([targetPath '/*']);
fprintf('Output folder is cleared!\n')

%% Dicom2Nifti %%
% first, prescan volumes are converted
cd(targetPath);
mkdir('converted_Weight_Volumes');
TE_prescan = RB_ME_PAID_Dicom2Nifti(prescanPath, numberOfEchoes);
unix(['mv ' prescanPath '/*.nii ' targetPath '/converted_Weight_Volumes']);

% then, all remaining (ie functional) volumes are converted
cd(targetPath);
mkdir('converted_Volumes');
TE = RB_ME_PAID_Dicom2Nifti(sourcePath, numberOfEchoes);
cd(sourcePath);
filesToBeMoved = dir('*.nii');
filesToBeMoved = char(filesToBeMoved.name);
fileMoveForLinux(sourcePath, [targetPath '/converted_Volumes'], filesToBeMoved, 100);
fprintf('DICOMs are converted!\n')


%% Realignment %%
% first handle first echo:
% grab all prescan .nii files of first echo
fprintf('Realignment of prescan volumes started\n');
cd([targetPath '/converted_Weight_Volumes']);
filesTemp = dir('*01.nii');
filesPrescan = char(zeros(length(filesTemp),length(filesTemp(1).name)+2,numberOfEchoes));
for i=1:size(filesPrescan,1)
    filesPrescan(i,1:length(filesTemp(i).name),1) = filesTemp(i).name;
end
% grab all functional .nii files of first echo
cd([targetPath '/converted_Volumes']);
filesTemp = dir('*01.nii');
files = char(zeros(length(filesTemp),length(filesTemp(1).name)+2,numberOfEchoes));
for i=1:size(files,1)
    files(i,1:length(filesTemp(i).name),1) = filesTemp(i).name;
end
% move all prescan files (first echo only) to functional folder. This is to
% ensure that all volumes (prescans and functional) are aligned to the same
% orientation. Otherwise, the prescans will be aligned, and the functional
% images will be aligned, but they will not match each other (e.g. voxel at
% coordinates (10,10) might be brain in prescans, but outside the head for
% functional). 
cd([targetPath '/converted_Weight_Volumes']);
filesToBeMoved = dir('*01.nii');
filesToBeMoved = char(filesToBeMoved.name);
fileMoveForLinux([targetPath '/converted_Weight_Volumes'], [targetPath '/converted_Volumes'], filesToBeMoved, 1000);
cd([targetPath '/converted_Volumes']);
filesFirstEcho = cat(1,filesPrescan(:,:,1),files(:,:,1));
% now, realign all volumes of first echo (prescans + functional) to first
% volume of prescans.
spm_realign(filesFirstEcho(:,:,1));
% and finally, move first echoes of prescan back to their original directory
fileMoveForLinux([targetPath '/converted_Volumes/'], [targetPath '/converted_Weight_Volumes'], filesPrescan(:,1:end-2,1), 1000);

% now, apply the same realignment transformations to all other echoes
% first, the prescans
cd([targetPath '/converted_Weight_Volumes']);
for j=2:numberOfEchoes
    filesTemp = dir(['*' num2str(j) '.nii']); % assuming number of echoes is less than 10!
    for i=1:size(filesPrescan(:,:,j),1)
        filesPrescan(i,1:length(filesTemp(i).name),j) = filesTemp(i).name;
    end
end
% Transformation matrices of all volumes of all echoes
% (except first echo) are changed to the matrix of first echo,
% thus, realigned.
for i=1:size(filesPrescan,1)
    VPrescan{1} = spm_get_space(filesPrescan(i,:,1));
    for j=2:size(TE,2)
        % realigned using spm_get_space
        spm_get_space(filesPrescan(i,:,j),VPrescan{1});
    end
end
% Now, apply the same process to the remaining echoes of the functional
% images
cd([targetPath '/converted_Volumes']); %% all the other volumes are realigned
for j=2:size(TE,2)
    filesTemp = dir(['*' num2str(j) '.nii']); %% assuming number of echoes is less than 10!
    for i=1:size(filesTemp,1)
        files(i,1:length(filesTemp(i).name),j) = filesTemp(i).name;
    end
end
for i=1:size(files,1)
    V{1} = spm_get_space(files(i,:,1));
    for j=2:size(TE,2)
        spm_get_space(files(i,:,j),V{1});
    end
end
fprintf('Realignment finished!\n')

%% reslice all volumes
%%%% TODO: implement this this bit (maybe in conjunction with previous step?)
%%%% more efficiently... 
% move prescan images into folder of functional images
for i=1:numberOfEchoes
    fileMoveForLinux([targetPath '/converted_Weight_Volumes'], [targetPath '/converted_Volumes'], filesPrescan(:,1:end-2,i), 1000); % TODO: Why 1:end-2 in filesPrescan(..)??
end
cd([targetPath '/converted_Volumes']);
resliceFiles = dir('*.nii');
resliceFiles = char(resliceFiles.name);
% reslice all images, relative to first prescan volume (i.e. the same one
% as the realignment is relative to)
spm_reslice(resliceFiles); 
% move prescan images and their headers back to the prescan folder
for i=1:numberOfEchoes
    fileMoveForLinux([targetPath '/converted_Volumes'], [targetPath '/converted_Weight_Volumes'], filesPrescan(:,1:end-2,i), 1000); % move images
    fileMoveForLinux([targetPath '/converted_Volumes'], [targetPath '/converted_Weight_Volumes'], cat(2,repmat('r',[numberOfWeightVolumes 1]),filesPrescan(:,1:end-2,i)), 1000); % move newly created headers
end
fprintf('Reslicing finished!\n')

%% Weight Calculation%%
% initialize
dimVolume = spm_vol(files(1,:,1));
dim = dimVolume.dim;
volume4D = zeros(dim(1),dim(2),dim(3),numberOfWeightVolumes,numberOfEchoes);

% get timeseries of prescans
cd([targetPath '/converted_Weight_Volumes']);
for iVol=1:numberOfWeightVolumes
    for iEcho=1:numberOfEchoes
        V{iEcho} = spm_vol([smoothingPrefix filesPrescan(iVol,:,iEcho)]);
        volume4D(:,:,:,iVol,iEcho) = spm_read_vols(V{iEcho});
    end
end

% calculate weights based on tSNR of prescan timeseries(c.f. Poser et al., (2006).
% doi:10.1002/mrm.20900)
tSNR = zeros(dim(1),dim(2),dim(3),numberOfEchoes);
CNR = zeros(dim(1),dim(2),dim(3),numberOfEchoes);
weight = zeros(dim(1),dim(2),dim(3),numberOfEchoes);
for j=1:numberOfEchoes
    tSNR(:,:,:,j) = mean(volume4D(:,:,:,:,j),4)./std(volume4D(:,:,:,:,j),0,4);
    CNR(:,:,:,j) = tSNR(:,:,:,j) * TE(j);
end
CNRTotal = sum(CNR,4);
for i=1:numberOfEchoes
    weight(:,:,:,i) = CNR(:,:,:,i) ./ CNRTotal;
end

% combine echos of all functional images using weights calculated based on
% prescans
I = zeros(dim(1),dim(2),dim(3),numberOfEchoes);
cd([targetPath '/converted_Volumes']);
for i=1:size(files,1)
    % grab all volumes of same timepoint
    for j=1:numberOfEchoes
        V{j} = spm_vol(['r' files(i,:,j)]);
    end
    
    % create new volume variable
    newVolume = V{1};
    % change filename of new volume
    if i<10
        newVolume.fname = [filename_base '.000' num2str(i) '.nii'];
    elseif i<100
        newVolume.fname = [filename_base '.00' num2str(i) '.nii'];
    elseif i<1000
        newVolume.fname = [filename_base '.0' num2str(i) '.nii'];
    else
        newVolume.fname = [filename_base '.' num2str(i) '.nii'];
    end
    
    % combine echoes of current timepoint
    I_weighted = zeros(newVolume.dim);
    for j=1:numberOfEchoes
        I(:,:,:,j) = spm_read_vols(V{j});
        I_weighted = I_weighted + I(:,:,:,j).*weight(:,:,:,j);
    end
    
    % write new volume to disk
    spm_create_vol(newVolume);
    spm_write_vol(newVolume,I_weighted);
end
% rename combination header file 
cd([targetPath '/converted_Volumes']);
listing=dir('mean*.nii');
copyfile(listing(1,1).name,['me.combination.mean.',filename_base,'.nii'])
% since we have resliced and realigned relative to first prescan, we have
% now more the realignment parameters for all volumes in header. Let's
% split them into header_prescans and header_function:
%%% rename realignment header file
cd([targetPath '/converted_Volumes']);
file_prescans = ['prescans_realignment.parameters.',filename_base,'.txt']; % new file
file_functional = ['realignment.parameters.',filename_base,'.txt'];
listing=dir('r*.txt'); 
copyfile(listing(1,1).name, file_functional ); % rename realignment file
move_first_nLines_to_otherFile(file_functional , file_prescans, numberOfWeightVolumes);
fprintf('Volumes are combined!\n')
cd(oldFolder);

end