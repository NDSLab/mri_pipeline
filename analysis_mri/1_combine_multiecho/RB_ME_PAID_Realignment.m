function output = RB_ME_PAID_Realignment(sourcePath,prescanPath,TE)

% here, sourcePath is the directory for .nii files which will be aligned
% to first file in presacnPath directory! 

if sourcePath == prescanPath
    cd(sourcePath);
    disp('Realignment started')

    filesTemp = dir('*01.nii');
    files = char(zeros(length(filesTemp),length(filesTemp(1).name)+2,size(TE,2)));
    for i=startVolume:size(files,1)
        files(i,1:length(filesTemp(i).name),1) = filesTemp(i).name;
    end

    spm_realign(files(:,:,1)); %% first echo volumes is realigned to the first volume of first echo

    for j=2:size(TE,2)
        filesTemp = dir(['*' num2str(j) '.nii']); %% assuming number of echoes is less than 10!
        for i=startVolume:size(files(:,:,j),1)
            files(i,1:length(filesTemp(i).name),j) = filesTemp(i).name;
        end
    end

    for i=1:size(files,1)

        V{1} = spm_vol(files(i,:,1));

        for j=2:size(TE,2) 
            V{j} = spm_vol(files(i,:,j)); %% Transformation matrices of all volumes of all echoes 
            I = spm_read_vols(V{j}); %% (except first echo) are changed to the matrix of first echo,
            V{j}.mat = V{1}.mat; %% thus, realigned.
            spm_write_vol(V{j},I);        
        end
    end

    disp('Realignment finished!')
end