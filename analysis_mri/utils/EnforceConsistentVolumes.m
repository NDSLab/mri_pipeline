function FILENAMES = EnforceConsistentVolumes(FILENAMES)
% ------------------------------------------------------------------
%
% Enforce same number of volumes for each echo
%
% ------------------------------------------------------------------
% make sure that all echoes have the same amount of images (delete any
% volume names from the list where not all echoes are available).
% Otherwise, combining the echoes won't work.
% 
% Background: 
% if you manually stop the scanner, you can end up with different amounts
% of volumes for the different echoes. This is why we need this..
%
% Input:
%       FILENAMES           ... cell-array of filenames, 
%                               with dimensions: {runs, echoes}
% 
% Output:
%       FILENAMES           ... cell-array of filenames, same dimensions as
%                               the input, but same number of entries for
%                               all echoes.
% 

[nRuns, nEchoes] = size(FILENAMES);


for iRun = nRuns:-1:1 % starting with largest index essentially pre-allocates memory :)
    % count how many volumes actually listed in each run
    for iEcho = nEchoes:-1:1
        tmp = FILENAMES{iRun,iEcho}; % get list of files (char-matrix)
        nVolumes(iEcho) = size(tmp,1); 
    end
    
    % find any mismatch among nVolumes
    ind = find( nVolumes(:) > min(nVolumes) )';
    % if any found, remove the trailing volumes from the filename list
    if ~isempty(ind)
        % log skipping of echoes
        fprintf('Unequal amounts of volumes found in run %i. Going to ignore %i DICOMs.\n', iRun, length(ind) );
        for i = ind
            % get  list of files
            tmp = FILENAMES{iRun,i};
            nTooMany = nVolumes(i) - min(nVolumes);
            FILENAMES{iRun,i} = tmp(1:(end-nTooMany),:);
        end
    end
end
end