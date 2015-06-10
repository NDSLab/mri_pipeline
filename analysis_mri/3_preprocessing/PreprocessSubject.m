function PreprocessSubject(SUBJECT_NUMBER, SESSION_NUMBER)

if ~exist('logs','dir'); mkdir('logs'); end
diary(['logs/preprocessing_subject' num2str(SUBJECT_NUMBER) '.log'])
tic

% set default session number
if ~exist('sessionNumber','var')
    SESSION_NUMBER=1;
end

addpath('../utils');

LoadSPM();
spm_jobman('initcfg');

% load potentially existing checkpoint-file
checkpointFilename = [pwd '/checkpoint_' num2str(SUBJECT_NUMBER,'%03d') '_' num2str(SESSION_NUMBER,'%03d'),'.mat'];
if exist(checkpointFilename,'file')
    fprintf('loading previous checkpoint data\n')
    load(checkpointFilename);
end
if ~exist('checkpoint','var')
    fprintf('no checkpoint variable defined - starting from step 1\n')
    checkpoint = 1;
    workMissing = true;
end


try
    % load subject specific details
    s = GetSubjectProperties(SUBJECT_NUMBER, SESSION_NUMBER);
    
    while workMissing
        switch checkpoint
            case 1
                fprintf('Starting with checkpoint %i\n', checkpoint);
                
                %- set settings for converting structural images
                %-------------------------------------------------
                % load matlabbatch variable
                clear matlabbatch; % to be sure to start with a fresh job description
                run('spm_structural_job.m');
                
                % overwrite subject-specific job-stuff
                matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_named_dir.dirs = {{s.dataRawPath}};
                matlabbatch{3}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.parent = {s.subjectFolder};
                matlabbatch{2}.cfg_basicio.file_dir.file_ops.file_fplist.filter = sprintf('%s\\.%04d',upper(s.scannerName), s.structuralSeries); % filter files based on scannername and series number

                %- assert raw data still present, otherwise skip this step
                %----------------------------------------------------------
                fileFilter = sprintf('%s/*%s.%04d*',s.dataRawPath, upper(s.scannerName),s.structuralSeries);
                if ~( exist(s.dataRawPath,'dir') && ...
                        ~isempty(dir(fileFilter)) )

                    fprintf('No structural DICOM files found. Skipping DICOM to Nifti conversion');

                    % advance checkpoint
                    %---------------------
                    checkpoint = checkpoint + 1;
                    
                    % jump to next checkpoint
                    continue
                end
                % if continue not triggered, structural files are present
                
                %- run SPM job
                %-----------------
                fprintf('converting structural DICOMs to Nifti...\n');
                spm_jobman('run', matlabbatch);
                fprintf('converting structural DICOMs to Nifti - done\n');
                
                %- advance checkpoint
                %----------------------
                checkpoint = checkpoint + 1;
                
            case 2
                fprintf('Starting with checkpoint %i\n', checkpoint);
                                
                %- set settings for functional data preprocessing
                %--------------------------------------------------
                % load matlabbatch variable
                clear matlabbatch; % to be sure to start with a fresh job description
                run('spm_preprocessing_job.m');
                
                % overwrite subject-specific variables
                matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_named_dir.dirs = {{[s.subjectFolder '/data_structural']}};
                matlabbatch{2}.cfg_basicio.file_dir.dir_ops.cfg_named_dir.dirs = {{s.dataCombinedPath}};
                
                %- run SPM job
                %-----------------
                fprintf('Preprocessing functional images... \n');
                spm_jobman('serial', matlabbatch);
                fprintf('Preprocessing functional images - done\n');
                 
                %- advance checkpoint
                %----------------------
                checkpoint = checkpoint + 1;
                workMissing = 0;
        end
    end
    
    
catch err
    
    fprintf('ERROR: could not preprocess subject %i\n',SUBJECT_NUMBER);
    fprintf('ERROR: %s\n',err.message);
    timestamp = datestr(now,30);
    error_filename = ['error' timestamp];
    save(error_filename,'err','matlabbatch');
end
toc
fprintf('finished proprocessing at %s\n', datestr(now));
diary off;

end

