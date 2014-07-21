function status=fileMoveForLinux(sourceDirectory,targetDirectory,filesToBeMoved,filePerCycle)

cd(sourceDirectory);
% filesToBeMoved = dir('*.nii');
% filesToBeMoved = char(filesToBeMoved.name);
filesToBeMoved = cat(2, repmat(sourceDirectory,size(filesToBeMoved,1),1), repmat('/',size(filesToBeMoved,1),1), filesToBeMoved,...
                            repmat(' ',size(filesToBeMoved,1),1));
for i=1:ceil(size(filesToBeMoved,1)/filePerCycle)
    if i==ceil(size(filesToBeMoved,1)/filePerCycle)
        unix(['mv ' reshape(permute(filesToBeMoved((i-1)*filePerCycle+1:end,:),[2 1]), 1 , size(filesToBeMoved,2)*(size(filesToBeMoved,1)-(i-1)*filePerCycle))...
                targetDirectory]);
    else
        unix(['mv ' reshape(permute(filesToBeMoved((i-1)*filePerCycle+1:i*filePerCycle,:),[2 1]), 1, size(filesToBeMoved,2)*filePerCycle) targetDirectory]);
    end
end

status=1;