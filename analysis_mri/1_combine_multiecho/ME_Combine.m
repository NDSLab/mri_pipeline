function varargout = ME_Combine(sourcePath, targetPath, nEchoes, numberOfWeightVolumes, filename_base, TE)
%% Initialization %%
addpath('/home/common/matlab/spm8');
oldFolder = pwd;
cd(sourcePath) % work inside 'uncombined' folder

%% Display folders and variables
fprintf('Input folder:\n%s\n',sourcePath);
fprintf('Output folder:\n%s\n',targetPath);
fprintf('nEchoes: %d\n', nEchoes);
fprintf('nWeightVolumes: %d\n', numberOfWeightVolumes);
toc


%% collect all nifti files, and sort by echo
filesTemp = dir([sourcePath '/rf*01.nii']); % just grab first echo... and be sure it's one of the uncombined ,ie starting with an 'f'
files = char(zeros(length(filesTemp),length(filesTemp(1).name)+2,nEchoes)); % ... to initialize char-matrix
for iEcho = 1:nEchoes
    filesTemp = dir([sourcePath '/rf*0' int2str(iEcho) '.nii']); % grab all uncombined echoes
    for i=1:size(filesTemp,1)
        files(i,1:length(filesTemp(i).name),iEcho) = filesTemp(i).name;
    end
end

%% Weight Calculation%%
% initialize
dimVolume = spm_vol(files(1,:,1));
dim = dimVolume.dim;
volume4D = zeros(dim(1),dim(2),dim(3),numberOfWeightVolumes,nEchoes);

% get timeseries of prescans
for iVol=1:numberOfWeightVolumes
    for iEcho=1:nEchoes
        V = spm_vol(files(iVol,:,iEcho));
        volume4D(:,:,:,iVol,iEcho) = spm_read_vols(V);
    end
end

% calculate weights based on tSNR of prescan timeseries(c.f. Poser et al., (2006).
% doi:10.1002/mrm.20900)
tSNR = zeros(dim(1),dim(2),dim(3),nEchoes);
CNR = zeros(dim(1),dim(2),dim(3),nEchoes);
weight = zeros(dim(1),dim(2),dim(3),nEchoes);
for j=1:nEchoes
    tSNR(:,:,:,j) = mean(volume4D(:,:,:,:,j),4)./std(volume4D(:,:,:,:,j),0,4);
    CNR(:,:,:,j) = tSNR(:,:,:,j) * TE(j);
end
CNRTotal = sum(CNR,4);
for i=1:nEchoes
    weight(:,:,:,i) = CNR(:,:,:,i) ./ CNRTotal;
end
fprintf('Weights calculated\n');
toc

% combine echos of all functional images using weights calculated based on
% prescans
clear V; % delete previously used 'V' variable..
I = zeros(dim(1),dim(2),dim(3),nEchoes);
for i=(numberOfWeightVolumes+1):size(files,1)
    % grab all volumes of same timepoint
    for j=1:nEchoes
        V{j} = spm_vol(files(i,:,j));
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
    for j=1:nEchoes
        I(:,:,:,j) = spm_read_vols(V{j});
        I_weighted = I_weighted + I(:,:,:,j).*weight(:,:,:,j);
    end
    
    % write new volume to disk
    spm_create_vol(newVolume);
    spm_write_vol(newVolume,I_weighted);
end
fprintf('Volumes are combined!\n')
toc

% move all new, combined volumes to new folder
filesToBeMoved=dir([filename_base '*.nii']);
filesToBeMoved = char(filesToBeMoved.name);
fileMoveForLinux(sourcePath, targetPath,filesToBeMoved,100);

fprintf('all files moved to %s\n',targetPath);
toc

% and return to starting folder
cd(oldFolder);
end