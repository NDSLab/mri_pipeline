function nMissingDicoms = AssertCorrectNumberOfDicoms(subject)
nMissingDicoms = [];
%% fill up setttings
s = GetSubjectProperties(subject,1);

%- set settings, like, for combining
RUN_SERIES                    = s.runSeries;
DIR_DATA                      = s.dataRawPath;
if length(s.nEchoes) > 1
    N_ECHOES = s.nEchoes;
else
    N_ECHOES = repmat(s.nEchoes,size(RUN_SERIES));
end
    
if exist(DIR_DATA,'dir')
    
    %% get list of all DICOM filenames
    % step 1.1: get all filenames - filenames are absolute path
    filenamesDicoms = GetAllDicomNames(RUN_SERIES,N_ECHOES,DIR_DATA);
    
    % step 1.2: remove any 'dangling' volumes
    filenamesDicomsFiltered = EnforceConsistentVolumes(filenamesDicoms);
    
    %% compare number of DICOMs to expected number of volumes
    for iRun = 1:length(RUN_SERIES)
        nMissingDicoms(iRun) = s.nVolumes(iRun) - length(filenamesDicomsFiltered{iRun,1});
    end
    
    if any(nMissingDicoms)
        ind = find(nMissingDicoms);
        for i=ind
            fprintf('Subject %i - Run %i - %i missing volumes (%i found)\n',subject, i, nMissingDicoms(i), s.nVolumes(i)-nMissingDicoms(i));
        end
    else
        fprintf('Subject %i - correct amount of DICOMS found\n', subject);
    end
    
else
    fprintf('Subject %i --- no raw data available\n');
end

end