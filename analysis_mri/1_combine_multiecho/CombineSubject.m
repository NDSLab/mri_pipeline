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
fprintf('========================================================\n');
fprintf('========================================================\n');
fprintf('%s - Starting combination script for subject %i\n',datestr(now),subj_nr);
fprintf('========================================================\n');

folder_start = pwd;
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
        fprintf('Current checkpoint: %d\n',checkpoint);
        toc

        switch checkpoint
            case 1
                %%%% checkpoint 1
                % create folder structure, and move images into appropriate folders
                
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
                    
                    % and run a mini check to assert expected meta-data
                    % format
                    if length(nEchoes) > 1 % ie echoes differ between runs
                        assert(length(nEchoes) == length(runSeries), 'Error in scan_metadata.m: nEchoes must be a single integer or the same length as "runSeries"');
                    else
                        nEchoes = repmat(nEchoes,size(runSeries));
                    end
                    
                else
                    error('Error loading subject-specific settings file. File "%s" not found',subject_settings_file);
                end
                
                % print some info (for log-file)
                fprintf('Structural File Series: %s\n', mat2str(structuralSeries));
                fprintf('Localizer File Series: %s\n', mat2str(localizerSeries));
                fprintf('Series corresponding to first echo of each run: %s\n', mat2str(runSeries));
                fprintf('Number of Echoes: %s\n', mat2str(nEchoes));
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
        
                
                % create list of files to be converted:
                for iRun = nRuns:-1:1
                    currentNEchoes = nEchoes(iRun);
                    for iEcho = currentNEchoes:-1:1
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
                    
                    currentNEchoes = nEchoes(iRun);
                    for iEcho = currentNEchoes:-1:1
                        fprintf('converting images of run %i and echo %i\n',iRun,iEcho);
                        toc
                        
                        
                        % grab headers of files
                        fileList = list_dicoms{iRun,iEcho};
                        hdr = spm_dicom_headers(fileList);
                        
                        % save echo time for combine-script
                        TERun(iEcho) = hdr{1}.EchoTime;
                        % convert dicom to nifti
                        tmp = spm_dicom_convert(hdr,'mosaic','flat','nii');
                        
                        list_nifti{iRun,iEcho} = tmp;
                    end
                    
                    TE{iRun} = TERun;
                    tmpFileList = dir([targetPath '/*.nii']);
                    fprintf('%i nii-files now in directory: %s\n', size(tmpFileList,1), targetPath);
                end
                cd(oldFolder);
                fprintf('DICOMs converted to NifTi\n');
                toc
                
                % after this, go to:
                checkpoint = 3.1 ;
                
                
            case 3.1
                %%%% checkpoint 3.1
                % realign and reslice all runs to first one
                % Then, in the next step, we don't need to realign any
                % more
                fprintf('Realigning functional runs\n');
                
                % collect all files from each run into cell array
                filesAll = {};
                for iRun = 1:nRuns
                    sourcePath = [uncombinedData,'/functional/run', num2str(iRun),'/nifti'];
                    
                    %%% collect all nifti files, and sort by echo
                    filesTemp = dir([sourcePath '/f*01.nii']); % just grab first echo... and be sure it's one of the uncombined ,ie starting with an 'f'
                    files = char(zeros(length(filesTemp),length(sourcePath) + length(filesTemp(1).name)+2,max(nEchoes))); % ... to initialize char-matrix
                    for iEcho = 1:nEchoes(iRun)
                        filesTemp = dir([sourcePath '/f*0' int2str(iEcho) '.nii']); % grab all uncombined echoes
                        for i=1:size(filesTemp,1)
                            tmp = cat(2, sourcePath,'/', filesTemp(i).name);
                            files(i,1:length(tmp),iEcho) = tmp;
                        end
                    end
                    filesAll{iRun} = files;
                    nFilesRun(iRun) = size(files,1); % save number of images per run for splitting realignment parameter file
                end
                % convert cell array into large matrix
                files = concatFiles(filesAll);
                
                %%% Realignment %%
                % first handle first echo:
                fprintf('Realignment started\n');
                toc
                
                % realing first echo
                spm_realign(files(:,:,1));
                
                fprintf('Realignment of first echo done\n');
                % Transformation matrices of all volumes of all echoes
                % (except first echo) are changed to the matrix of first echo,
                % thus, realigned.
                for i=1:size(files,1)
                    VPrescan{1} = spm_get_space(files(i,:,1));
                    for j=2:nEchoes
                        % realigned using spm_get_space
                        spm_get_space(files(i,:,j),VPrescan{1});
                    end
                end
                
                fprintf('Realignment finished!\n')
                toc
                
                %%% reslice all volumes
                fprintf('Reslicing started\n')
                % reslice all images, relative to first prescan volume (i.e. the same one
                % as the realignment is relative to)
                tmpFiles = reshape_along_3rd(files); % _reslice needs a 2d matric of names
                spm_reslice(tmpFiles);
                
                fprintf('Reslicing is finished!\n')
                toc
                
                checkpoint = 3.2;
                
            case 3.2
                 
                fprintf('Processing realignment parameter file\n');
                %%% split realignment parameter file into appropriate pieces
                % i.e. one per run, and removing the prescans into
                % dedicated file
                % since we have resliced and realigned relative to first prescan, we have
                % now more the realignment parameters for all volumes in header. Let's
                % split them into header_prescans and header_function, and move them to the
                % target folder
                sourcePath = [uncombinedData,'/functional/run1/nifti'];
                tmpFolder = pwd;
                cd(sourcePath);
                listing=dir('rp*.txt');
                file_rp = listing(1,1).name;
                copyfile(file_rp, [file_rp '.backup']); % save backup copy.. 
                
                for iRun = 1:nRuns
                    outputPath = [combinedData,'/functional/run', num2str(iRun)];
                    filename_base=[subjectName,'.session',num2str(session_nr),'.run', num2str(iRun)];
                    
                    file_wholeRun =   ['realignment.parameters.all.' filename_base '.txt'];
                    file_prescans =   ['realignment.parameters.prescans.',filename_base,'.txt'];
                    file_functional = ['realignment.parameters.',filename_base,'.txt'];
                    removeFileIfExists(file_functional);
                    removeFileIfExists(file_prescans);
                    removeFileIfExists(file_wholeRun);
                    % first, take current run's realignment parameter part
                    move_first_nLines_to_otherFile(file_rp, file_wholeRun, nFilesRun(iRun));
                    % copy this into file_functional
                    copyfile(file_wholeRun, file_functional);
                    % and move first x lines into file_prescans
                    move_first_nLines_to_otherFile(file_functional,file_prescans,nWeightVolumes);
                    
                    % and move files to output folder:
                    fileMoveForLinux(sourcePath, outputPath, file_wholeRun, 100);
                    fileMoveForLinux(sourcePath, outputPath, file_prescans ,100);
                    fileMoveForLinux(sourcePath, outputPath, file_functional ,100);
                end
                                
                
                % move combination header file into folder of functional
                % runs
                listing=dir('mean*.nii');
                copyfile(listing(1,1).name,['me.combination.mean.',filename_base,'.nii']);
                fileMoveForLinux(sourcePath, [combinedData '/functional'], ['me.combination.mean.',filename_base,'.nii'] ,100);
                
                cd(tmpFolder);
                
                % after this, go to:
                checkpoint = 3.3;
                
            case 3.3
                %%%% checkpoint 3.2
                % Start Multi Echo Combination -- one run at a time
                fprintf('Starting combination of echoes\n');
                
                
                for iRun=1:nRuns
                    fprintf('combining echoes of run %i\n', iRun);
                    toc
                    
                    sourcePath = [uncombinedData,'/functional/run', num2str(iRun),'/nifti'];
                    outputPath = [combinedData,'/functional/run', num2str(iRun)];
                    filename_base=[subjectName,'.session',num2str(session_nr),'.run', num2str(iRun)];
                    
                    currentNEchoes = nEchoes(iRun);
                    ME_Combine(sourcePath,outputPath,currentNEchoes,nWeightVolumes,filename_base, TE{iRun});
                end
                fprintf('All echoes combined\n');
                
                % after this, go to:
                checkpoint = 4;
                
            case 4
                %%%% Checkpoint 4:
                % copy combined data, and clean up afterwards
                fprintf('cleaning up file structure\n');
                                
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
        
        save(checkpoint_filename)
    end
    
    fprintf('========================================================\n');
    fprintf('\nCombination of all functional images are completed: %s\n',combinedData);
    fprintf('========================================================\n');
    toc
    
    %%% end %%%%
    cd(folder_start) 
    
    % if reaching this point, we're done. Thus delete the checkpoint
    if exist(checkpoint_filename,'file')
        delete(checkpoint_filename)
    end
    
catch err
    save(checkpoint_filename)
    cd(folder_start)
    rethrow(err);
end




end
