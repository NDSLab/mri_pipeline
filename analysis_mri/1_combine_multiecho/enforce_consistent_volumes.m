function list_dicoms = enforce_consistent_volumes(list_dicoms)
% make sure that all echoes have the same amount of images (delete any
% volumes where not all echoes are available). Otherwise, combining the
% echoes won't work.
% 
% NOTE: if you manually stop the scanner, you can end up with different
% amounts of volumes for the different echoes. This is why we need this.. 


[nRuns, nCol ] = size(list_dicoms);

for iRun = 1:nRuns
    % determine the number of echoes for current run
    for iCol = nCol:-1:1 
        if ~isempty(list_dicoms{iRun,iCol})
            nEchoes(iRun) = iCol;
            break;
        end
    end
end

for iRun = nRuns:-1:1 % starting with largest index essentially pre-allocates memory :)
    for iEcho = nEchoes(iRun):-1:1
       tmp = list_dicoms{iRun,iEcho}; % get list of files (char-matrix)
       for iLine = size(tmp,1):-1:1
           if length(tmp(iLine,:)) > 0 
               break;
           end
       end
       nVolumes(iEcho) = iLine;
    end
    
    
    ind = find( nVolumes(:) > min(nVolumes) );
    if ~isempty(ind)
        fprintf('Unequal amounts of volumes found. Going to skip last %i DICOMs\n', length(ind));
        for i = ind
            % get  list of files
            tmp = list_dicoms{iRun,i};
            nTooMany = nVolumes(i) - min(nVolumes);
            list_dicoms{iRun,i} = tmp(1:(end-nTooMany),:);
        end
    end
end

end