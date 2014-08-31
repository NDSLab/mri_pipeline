function CombineSubject( subj_nr, session_nr, use_checkpoints )
% CombineSubject(subject_nr, session_nr, use_checkpoints)
%   combines subject multi-echo data
%   Input:
%       subject_nr      .... subject number
%       session_nr      .... [optional] session number, default: 1
%       use_checkpoints .... [optional] use checkpoints to avoid doing the
%                            same step twice if error should happen, e.g.
%                            after copying files
%

tic
diary(['combineSubject_s' num2str(subj_nr) '.log'])

addpath('/home/common/matlab/spm8');
addpath(pwd); 

% check whether session id was provided, if not, assume sessionId=1
if ~exist('session_id','var')
    session_nr=1;
end

% use checkpoints per default
if ~exist('use_checkpoints','var')
    use_checkpoints = 1;
end

if use_checkpoints
    disp('using checkpoints')
    checkpoint_filename = [pwd '/checkpoint_' num2str(subj_nr,'%03d') '_' num2str(session_nr,'%03d'),'.mat'];
    
    % load existing checkpoint-file
    if exist(checkpoint_filename,'file')
        disp('loading previous data')
        load(checkpoint_filename);
    end
end


try
    if ~exist('checkpoint','var')
        disp('no checkpoint variable defined - starting from 1')
        checkpoint = 1;
        work_missing = 1;
    else
        if checkpoint > 1
            fprintf('previously, finished checkpoint %i - will continue next one\n\n',checkpoint-1);
        end
    end
    
    while work_missing
        switch checkpoint
            
            case 1
                %%%% checkpoint 1
                % create folder structure, and move images into appropriate folders
                disp('Starting with checkpoint 1')
                toc
                
                [path_str,filename, extension] = fileparts(mfilename('fullpath'));
                pathParts = strsplit(path_str,'/');
                
                project_folder = sprintf('%s/',pathParts{1:end-2});  % has trailing '/'
                project_number = pathParts{end-2};
                
                [~, user_name] = system('whoami'); user_name=user_name(1:end-1); % username contains trailing \n
                
                subject_folder=[project_folder project_number '_' user_name '_' num2str(subj_nr,'%03d') '_' num2str(session_nr,'%03d') '/'];
                dataRawPath=[subject_folder 'data_raw'];
                % Name of the subject folder in uncombined and combined data folders
                subjectName=['s' num2str(subj_nr)];
                
                str=sprintf('Combination of functional images started for subject %i',subj_nr);
                disp(str);
                
                str=sprintf('Input Folder: %s', dataRawPath);
                disp(str);
                
                %uncombined data folder for all subjects
                uncombinedData=[subject_folder 'data_uncombined'];
                %combined data folder for all subjects
                combinedData=[subject_folder 'data_combined'];
                
                % load meta-data, defined in /data_raw/scan_metadata.m
                subject_settings_file = [dataRawPath '/scans_metadata.m'];
                if exist(subject_settings_file,'file')
                    run(subject_settings_file);
                else
                    error('Error loading subject-specific settings file. File "%s" not found',subject_settings_file);
                end
                
                % print some info (for log-file)
                fprintf('Structural File Series: %s\n', mat2str(structuralSeries));
                fprintf('Localizer File Series: %s\n', mat2str(localizerSeries));
                fprintf('Series corresponding to first echo of each run: %s\n', mat2str(runSeries));
                fprintf('Number of prepscans for each run: %s\n', mat2str(prepscans));
                fprintf('Series corresponding to first echo of each prescan: %s\n', mat2str(prescanSeries));
                fprintf('Number of Echoes: %d\n', nEchoes);
                fprintf('Number of Prescan-Volumes: %d\n', nWeightVolumes);
                
                nRuns = length(runSeries);
                % Create folder structure in uncombined data folder
                for i=1:nRuns
                    mkdir([uncombinedData,'/functional/run', num2str(i),'/nifti']); % will contain the uncombined nifti images (incl. prescans)
                end
                
                % after this, go to:
                checkpoint = 2;
                
            case 2
                %%%% checkpoint 2
                % convert all relevant DICOMs to NifTi format and move them
                % into the appropriate folder
                fprintf('Converting DICOMs to NifTis\n');
                toc
                
                % create list of files to be converted:
                for iRun = nRuns:-1:1
                    for iEcho = nEchoes:-1:1
                        list_dicoms{iRun,iEcho} = get_dicom_names(runSeries(iRun)+(iEcho-1), dataRawPath);
                    end
                end
                % enforce that all echoes have the same number of scanned
                % volumes
                list_dicoms = enforce_consistent_volumes(list_dicoms);
                
                oldFolder = pwd;
                for iRun = nRuns:-1:1
                    % NOTE: SPM writes newly created nifti files to
                    % current directory, so we temporarily jump to the
                    % 'uncombined folder'
                    targetPath = [uncombinedData,'/functional/run', num2str(iRun),'/nifti'];
                    mkdir(targetPath); % make sure folder exists
                    cd(targetPath);
                    
                    for iEcho = nEchoes:-1:1
                        fprintf('converting images of run %i and echo %i\n',iRun,iEcho);
                        toc
                        
                        
                        % grab headers of files
                        hdr = spm_dicom_headers(list_dicoms{iRun,iEcho});
                        % save echo time for combine-script
                        TE(iEcho) = hdr{1}.EchoTime;
                        % convert dicom to nifti
                        list_nifti{iRun,iEcho} = spm_dicom_convert(hdr,'mosaic','flat','nii');
                    end
                    
                    tmpFileList = dir([targetPath '/*.nii']);
                    fprintf('%i nii-files now in directory: %s\n', size(tmpFileList,1), targetPath);
                end
                cd(oldFolder); 
                fprintf('DICOMs converted to NifTi\n');
                toc
                 
                % after this, go to:
                checkpoint = 3 ;
                
                
            case 3
                %%%% checkpoint 3
                % Start Multi Echo Combination -- one run at a time
                disp('Starting with checkpoint 2')
                toc
                
                for iRun=1:nRuns
                    fprintf('combining echoes of run %i\n', iRun);
                    toc
                    
                    sourcePath = [uncombinedData,'/functional/run', num2str(iRun),'/nifti'];
                    outputPath = [combinedData,'/functional/run', num2str(iRun)];
                    filename_base=[subjectName,'.session',num2str(session_nr),'.run', num2str(iRun)];
                    
                    ME_Combine(sourcePath,outputPath,nEchoes,nWeightVolumes,filename_base, TE);
                end
                
                % after this, go to:
                checkpoint = 4;
                
            case 4
                %%%% Checkpoint 4:
                % copy combined data, and clean up afterwards
                disp('Starting with checkpoint 3')
                toc
                
                % Create folder structure in combined data folder
                mkdir([combinedData,'/structural/dicom']);
                mkdir([combinedData,'/localizers']);
                
                % Copy structural files
                fprintf('Copying files from series: %s\n', mat2str(structuralSeries));
                outputFolder = [combinedData,'/structural/dicom'];
                copySeries(dataRawPath,outputFolder,structuralSeries,scannerName);
                
                % Copy localizer file series
                fprintf('Copying files from series: %s\n', mat2str(localizerSeries));
                outputFolder = [combinedData,'/localizers'];
                copySeries(dataRawPath,outputFolder,localizerSeries,scannerName);
               
                
                % Delete subject data in uncombined folder
                if deleteUncombinedData == 1
                    rmdir(uncombinedData,'s');
                    fprintf('uncombined data-files are deleted from directory: %s\n',uncombinedData);
                end
                
                % after this, go to:
                work_missing = 0; % after this, we're done
                
            otherwise
                fprintf('unknown checkpoint: %i\n',checkpoint);
        end
    end
    
    
    fprintf('\nCombination of all functional images are completed: %s\n',combinedData);
    toc
    
    %%% end %%%%
    
    
    % if reaching this point, we're done. Thus delete the checkpoint
    if exist(checkpoint_filename,'file')
        delete(checkpoint_filename)
    end
    
catch err
    save(checkpoint_filename)
    rethrow(err);
    diary off
end



end
