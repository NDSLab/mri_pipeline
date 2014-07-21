function [ filter ] = createDicomFilter( seriesNumber, scannerName)
% createDicomFilter( seriesNumber, scannerName) returns a file-name filter
% for all Dicom files of a series of a scanner 
% Input:
%       seriesNumber    ... seriesNumber, as shown on "Print-list"
%       scannerName     ... string identifying 
% for example: for seriesNumber 7 and scannerName = 'Skyra', it'll return 

% 
%% Create filter based on scannerName 
% Default: Skyra
if ~exist('scannerName','var')
    scannerName = 'Skyra';
    % provide user with warning
    fprintf('createDicomFilter: Warning - You have not provided a scanner-name')
    fprintf('createDicomFilter: Default is %s, but it is better to explicitly provide a value', scannername);
end
switch scannerName
    case 'Skyra'
        defExp='*SKYRA.';
    case {'Trio','Avanto'}
        defExp='*FMRI.';
end
        
%% We assume serýes number is less than 1000
    if seriesNumber < 10
        filter=[defExp,'000', num2str(seriesNumber),'*'];
    elseif seriesNumber < 100
        filter=[defExp,'00', num2str(seriesNumber),'*'];
    elseif seriesNumber < 1000
        filter=[defExp,'0', num2str(seriesNumber),'*'];
    else
        filter=[defExp,'', num2str(seriesNumber),'*'];
    end
end

