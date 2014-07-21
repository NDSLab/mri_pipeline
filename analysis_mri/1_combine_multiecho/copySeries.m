function copySeries( inputFolder, outputFolder, series, scannerName, firstVolume, lastVolume )
%COPYSERIES copies all files from a series, from inputFolder to the
% outputFolder. The optional arguments 'firstVolume' and 'lastVolume' limit
% how many volumes will be copied. If ;firstVolume' is defined (e.g. 31),
% then the first firstVolume-1 files will be skipped; if the 'lastVolume'
% is defined (e.g. 30), then only 1:lastFile will be copied.

% define with which volume to start
if ~exist('firstVolume','var')
    kStart = 1;
else 
    kStart = firstVolume;
end

nSeries = length(series);
for j=1:nSeries
    % get all files in series
    listing = dir([inputFolder,'/',createDicomFilter(series(1,j),scannerName)]);
    % copy files excluding prescans (ie volumes+1:end)
    
    % limit how many files we'll copy
    % Note: this might be different for the series, e.g. because one echo
    % contains more images than another (because scanner was stopped
    % manually)
    if ~exist('lastVolume','var')
        kLast = length(listing);
    else
        kLast = lastVolume;
    end
    for k=kStart:kLast
        copyfile([inputFolder,'/', listing(k,1).name],outputFolder);
    end
    showMessage(outputFolder,series, scannerName);
end

end

