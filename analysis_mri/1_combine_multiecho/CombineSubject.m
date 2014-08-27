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


diary(['combineSubject_s' num2str(subj_nr) '.log'])

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
    checkpoint_filename = ['checkpoint_' num2str(subj_nr,'%03d') '_' num2str(session_nr,'%03d'),'.mat'];
    
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
            fprintf('previously, finished checkpoint %i - will continue next one',checkpoint-1);
        end
    end
    
    while work_missing
        switch checkpoint
            
            case 1
                %%%% checkpoint 1
                % create folder structure, and move images into appropriate folders
                disp('Starting with checkpoint 1')
                
                [path_str,filename, extension] = fileparts(mfilename('fullpath'));
                pathParts = strsplit(path_str,'/');
                
                project_folder = sprintf('%s/',pathParts{1:end-2});  % has trailing '/'
                project_number = pathParts{end-2};
                
                [~, user_name] = system('whoami'); user_name=user_name(1:end-1); % username contains trailing \n
                
                subject_folder=[project_folder project_number '_' user_name '_' num2str(subj_nr,'%03d') '_' num2str(session_nr,'%03d') '/'];
                subjectData=[subject_folder 'data_raw'];
                % Name of the subject folder in uncombined and combined data folders
                subjectName=['s' num2str(subj_nr)];
                
                str=sprintf('Combination of functional images started for subject %i',subj_nr);
                disp(str);
                
                str=sprintf('Input Folder: %s', subjectData);
                disp(str);
                
                %uncombined data folder for all subjects
                uncombinedData=[subject_folder 'data_uncombined'];
                %combined data folder for all subjects
                combinedData=[subject_folder 'data_combined'];
                
                % load meta-data, defined in /data_raw/scan_metadata.m
                subject_settings_file = [subjectData '/scans_metadata.m'];
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
                fprintf('Number of Echoes: %d\n', echoes);
                fprintf('Number of Prescan-Volumes: %d\n', volumes);
                
                nRuns = length(runSeries);
                % Create folder structure in uncombined data folder
                for i=1:nRuns
                    mkdir([uncombinedData,'/functional/run', num2str(i),'/prescan']); % will contain the prescan-volumes
                    mkdir([uncombinedData,'/functional/run', num2str(i),'/dicom']); % will contain raw dicoms
                    mkdir([uncombinedData,'/functional/run', num2str(i),'/nifti']); % will contain converted, combined nifti files
                end
                
                
                % Copy prescan file series
                disp('Copying prescan files')
                for i=1:nRuns
                    series=prescanSeries(i):prescanSeries(i)+echoes-1;
                    fprintf('Copying files from series: %s\n', mat2str(series));
                    outputFolder = [uncombinedData,'/functional/run', num2str(i),'/prescan'];
                    copySeries(subjectData,outputFolder,series,scannerName,1,volumes); % e.g. only volumes 1:30
                end
                
                % Copy functional file series
                disp('Copying functional files')
                for i=1:nRuns
                    series=runSeries(i):runSeries(i)+echoes-1;
                    fprintf('Copying files from series: %s\n', mat2str(series));
                    nSeries = length(series);
                    outputFolder = [uncombinedData,'/functional/run', num2str(i),'/dicom'];
                    copySeries(subjectData,outputFolder,series,scannerName,volumes+1); % skip prescan volumes,e.g. 30:end
                    
                    % make sure that all echoes have the same amount of
                    % images (delete any volumes where not all echoes
                    % are available). Otherwise, combining the echoes won't
                    % work..
                    % Note: if you manually stop the scanner, you can
                    % end up with different amounts of volumes for the
                    % different echoes. This is why we need this..
                    nofArray=numberFilesPerSeries(outputFolder,series, scannerName);
                    if mean(nofArray)~=min(nofArray) % if one series contains a different amount of files
                        filesToMove=nofArray-min(nofArray)*ones(1,nSeries); % identify how many files to move, for each series
                        for j=1:nSeries
                            if filesToMove(j)>0 % if too many files in this series:
                                deleteLastFiles( outputFolder,series(j), filesToMove(1,j) );
                                listing=dir([outputFolder,'/',createDicomFilter(series(j),scannerName)]);
                                nf= length(listing);
                                % delete 'from the end'
                                for k=nf:-1:nf-filesToMove(j)+1
                                    delete([outputFolder,'/',listing(k,1).name])
                                end
                                fprintf('Last %d files of Series %d deleted from %s directory.\n', lastNo ,seriesNo, outputFolder);
                            end
                        end
                        % re-calculate the number of files in directory,
                        % and log it:
                        showMessage(outputFolder,series, scannerName);
                    end
                end
                
                fprintf('All files copied to uncombined-folder\n');
                
                % after this, go to:
                checkpoint = 2;
                
            case 2
                %%%% checkpoint 2
                % Start Multi Echo Combination -- one run at a time
                disp('Starting with checkpoint 2')
                
                for j=1:nRuns
                    prescanPath=[uncombinedData,'/functional/run', num2str(j),'/prescan'];
                    sourcePath= [uncombinedData,'/functional/run', num2str(j),'/dicom'];
                    targetPath= [uncombinedData,'/functional/run', num2str(j),'/nifti'];
                    filename_base=[subjectName,'.session',num2str(session_nr),'.run', num2str(j)];
                    
                    ME_Combine(prescanPath,sourcePath,targetPath,echoes,volumes,filename_base);
                end
                
                % after this, go to:
                checkpoint = 3;
                
            case 3
                %%%% Checkpoint 3:
                % copy combined data, and clean up afterwards
                disp('Starting with checkpoint 3')
                % Create folder structure in combined data folder
                mkdir([combinedData,'/structural/dicom']);
                mkdir([combinedData,'/localizers']);
                for j=1:nRuns
                    mkdir([combinedData,'/functional/run',num2str(j),'/prepscans']);
                end
                
                % Copy structural files
                fprintf('Copying files from series: %s\n', mat2str(structuralSeries));
                outputFolder = [combinedData,'/structural/dicom'];
                copySeries(subjectData,outputFolder,structuralSeries,scannerName);
                                
                % Copy localizer file series
                fprintf('Copying files from series: %s\n', mat2str(localizerSeries));
                outputFolder = [combinedData,'/localizers'];
                copySeries(subjectData,outputFolder,localizerSeries,scannerName);
                
                % Copy combined images, text files and means
                for i=1:nRuns
                    targetF=[combinedData,'/functional/run', num2str(i)];
                    sourceF=[uncombinedData,'/functional/run', num2str(i),'/nifti'];
                    copyfile([sourceF,'/converted_Volumes/*.nii'],targetF);
                    copyfile([sourceF,'/converted_Volumes/realignment.*.txt'],targetF);
                    copyfile([sourceF,'/converted_Volumes/me.combination*.nii'],[targetF,'/otherfiles']);
                end
                
                % copy prescans images, text files and means
                for i=1:nRuns
                    sourceF=[uncombinedData,'/functional/run',num2str(i),'/nifti/converted_Weight_Volumes'];
                    prescanF=[combinedData,'/functional/run',num2str(i),'/prescan'];
                    copyfile([sourceF,'/*'],targetF);
                    listing=dir([prescanF,'/','*.nii']);
                    fprintf('Number of files copied to %s directory: %d\n',prescanF, length(listing));
                end
%                    
%                 % Delete subject data in uncombined folder
%                 if deleteUncombinedData == 1
%                     rmdir(uncombinedData,'s');
%                     fprintf('Subject data files are deleted from directory: %s\n',uncombinedData);
%                 end
%                 
                % after this, go to:
                work_missing = 0; % after this, we're done
                
            otherwise
                fprintf('unknown checkpoint: %i\n',checkpoint);
        end
    end
    
    
    fprintf('\nCombination of all functional images are completed: %s\n',combinedData);
    %%% end %%%%

    % if reaching this point, we're done. Thus delete the checkpoint
    if exist(checkpoint_filename,'file')
        delete(checkpoint_filename)
    end
    
catch err
    cd(path_str);
    save([path_str '/' checkpoint_filename])
    rethrow(err);
    diary off
end

                

end
