function [ output_args ] = showMessage( folder, series, scannerName)
% showMessage counts all files in 'folder' belonging to the 'series' 
% and prints a message 
    noff=sum(numberFilesPerSeries(folder,series,scannerName));
    fprintf('%d files copied to directory: %s\n',noff,folder);
end

