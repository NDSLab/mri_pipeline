function [ nfa ] = numberFilesPerSeries(inputFolder, series, scannerName)
% numberFilesPerSeries counts the Dicom files present in inputFolder, per
% series and returns an array of size(series) containing the counts.
% Input:
%   inputFolder     ... path to where to count Dicom files
%   series          ... array of series-numbers (e.g. [7 11 15])
%   scannerName     ... string, identifying scanner-name (e.g. 'Skyra')

nfa=NaN(1,length(series));
for i=1:length(series)
    listing=dir([inputFolder,'/',createDicomFilter(series(1,i),scannerName)]);
    nfa(i) = length(listing);
end

end
