function status=fileMoveForLinux(sourceDirectory,targetDirectory,filesToBeMoved,filePerCycle)
status = 0;

% filesToBeMoved = dir('*.nii');
% filesToBeMoved = char(filesToBeMoved.name);

% if sourceDirectory is not part of the filenames, prepend it to make
% move-commands using full pathnames
needingPrepend = ~strfind(filesToBeMoved(1,:),sourceDirectory);
if needingPrepend
    filesToBeMoved = cat(2, repmat(sourceDirectory,size(filesToBeMoved,1),1),...
        repmat('/',size(filesToBeMoved,1),1), ...
        filesToBeMoved);
end

% make sure there are spaces at the end of the files, so that the unix mv
% command can work
filesToBeMoved = cat(2, filesToBeMoved,  repmat(' ',size(filesToBeMoved,1),1));

% make sure that targetFolder exists
mkdir(targetDirectory);

for i=1:ceil(size(filesToBeMoved,1)/filePerCycle)
    if i==ceil(size(filesToBeMoved,1)/filePerCycle)
        command = ['mv ' reshape(permute(filesToBeMoved((i-1)*filePerCycle+1:end,:),[2 1]), 1 , size(filesToBeMoved,2)*(size(filesToBeMoved,1)-(i-1)*filePerCycle))...
                ' ' targetDirectory];
        status = unix(command);
    else
        command = ['mv ' reshape(permute(filesToBeMoved((i-1)*filePerCycle+1:i*filePerCycle,:),[2 1]), 1, size(filesToBeMoved,2)*filePerCycle)  ' ' targetDirectory '/.'];
        status = unix(command);
    end
end

end