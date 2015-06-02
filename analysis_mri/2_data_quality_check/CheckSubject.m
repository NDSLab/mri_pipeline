function CheckSubject(SUBJECT_NUMBER, SESSION_NUMBER)

diary(['data_quality_check' num2str(SUBJECT_NUMBER) '.log'])

addpath('../utils')
addpath('/home/common/matlab/spm12');

% load spm-defaults;
spm_defaults;

% set default: session_number == 1
if ~exist('sessionNumber','var')
    SESSION_NUMBER=1;
end

fprintf('QUALITY CHECKS: starting checking subject %i (session %i) data\n', SUBJECT_NUMBER, SESSION_NUMBER)

% load potentially existing checkpoint-file
checkpointFilename = [pwd '/checkpoint_' num2str(SUBJECT_NUMBER,'%03d') '_' num2str(SESSION_NUMBER,'%03d'),'.mat'];
if exist(checkpointFilename,'file')
    fprintf('loading previous data\n')
    load(checkpointFilename);
end
if ~exist('checkpoint','var')
    fprintf('no checkpoint variable defined - starting from step 1\n')
    checkpoint = 1;
    workMissing = true;
end

% run steps using checkpoints
try
    
    subjectParameter = GetSubjectProperties(SUBJECT_NUMBER,SESSION_NUMBER);
    
    % define where to put output files
    folderOutput = fullfile(subjectParameter.subjectFolder, 'data_quality_checks');
    if ~exist(folderOutput, 'dir' ); mkdir(folderOutput); end % ensure the folder exists
    
    while workMissing
        switch checkpoint
            case 1
                %%%% checkpoint 1  - load image data into 4d array
                fprintf('Starting with checkpoint %i\n', checkpoint);
                
                %- set settings for loading image data
                %---------------------------------------
                folderImages = subjectParameter.dataCombinedPath;
                % file filter used by SPM - modify if you want to create videos from other images
                fileFilter = '^crf\S*nii$'; % use ^crf to get combined, but otherwise untouched images (ie not 'preprocessed')
                % whether SPM should decend into subfolders of 'folderImages' when looking for files
                decendIntoSubfolders = true;
                
                %- run function
                %-----------------
                data = LoadImageData(folderImages, fileFilter, decendIntoSubfolders);
                
                %- advance checkpoint
                %----------------------
                save(checkpointFilename)
                checkpoint = checkpoint + 1;
                
            case 2
                fprintf('Starting with checkpoint %i\n', checkpoint);
                %%% checkpoint 2 - Create Movies
                
                %- set movie-script settings
                %--------------------------------
                % folder where movies will be saved
                configMovie.folderOutput = folderOutput;
                % the following settings should note be changed unless you want to tweak the movie properties
                % Frames per second.
                configMovie.framesPerSecond = 6;
                % define a movie using 'brightness' clims definition
                configMovie.clims{1}.type = 'brightness';
                configMovie.clims{1}.value = 0.97; % Brightness value of movie. A value between -1 (very dark) and 1 (very bright) with 0 to leave the image as it is. Set to 0.97 to see the noise clearly.
                configMovie.movieFilenames{1} ='CheckMosaicMovie_default';
                % define movie using percentiles below/above which to clip:
                configMovie.clims{2}.type = 'percentile';
                configMovie.clims{2}.value(1) = 0.002; % percentile below which to clip to black
                configMovie.clims{2}.value(2) = 0.60; % percentile above which to clip to white
                configMovie.movieFilenames{2} = 'CheckMosaicMovie_contrast';
                
                %- run function
                %-----------------
                CreateMovie(configMovie, data);
                
                %- advance checkpoint
                %----------------------
                save(checkpointFilename)
                checkpoint = checkpoint + 1;
                
            case 3
                fprintf('Starting with checkpoint %i\n', checkpoint);
                %%% checkpoint 3 - create plots of intensity data
                %- set setting for histrogram plot
                %-----------------------------------
                % create histogram of data
                % Making a histogram of the data
                nbins = 128;
                titleString = sprintf('Histogram of subject %i - session %i', SUBJECT_NUMBER, SESSION_NUMBER);
                filenameHistogram = fullfile(folderOutput, [sprintf('Histogram_%i_%i', SUBJECT_NUMBER, SESSION_NUMBER) '.png' ]);
                %- run function
                %-----------------
                CreateHistogram(data,nbins,titleString,filenameHistogram)
                                
                %- create signal intensity curves
                % create intensity=f(time) plots
                titleString = sprintf('Check: signal - subject %i (session %i)',SUBJECT_NUMBER, SESSION_NUMBER);
                filenameSignal = fullfile(folderOutput, 'SignalCheck.png');
                %- run function
                %-----------------
                CreateMeanCurvePlot(data,titleString, filenameSignal);
                
                
                %- advance checkpoint
                %----------------------
                save(checkpointFilename)
                checkpoint = checkpoint + 1;
                
                       
            case 4
                fprintf('Starting with checkpoint %i\n', checkpoint);
                %%% checkpoint 4 - detect and optionally remove spikes
                
                % TODO: add Inge's code here
                
                % no need to save workspace - work_missing == 0
                checkpoint = checkpoint + 1;
                workMissing = 0;
                
        end
    end
    
    fprintf('\n\nChechking subject %i finished\n\n',SUBJECT_NUMBER);
    
    % if reaching this point, we're done. Thus delete the checkpoint
    if exist(checkpointFilename,'file')
        delete(checkpointFilename)
    end
    
catch err
    save(checkpointFilename)
    rethrow(err);
end


end

