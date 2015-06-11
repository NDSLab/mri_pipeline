function CheckSubject(SUBJECT_NUMBER, SESSION_NUMBER)
%
% Checks combined fMRI data per subject on spikes and 
%
% Spike detection:
% Select a small chunk of data by use of a mask to check it on spikes. A
% spike is defined by a datapoint that is larger than 30% lager than average
% slices.
%
% Movie 
%
% data should be nested as: 
%       /home/group/DCCN-user-id/~/mri_pipeline-master/mri_pipeline-master_DCCN-user-id_SUBJ_NR_SESSION_NR/
%       eg. 
%       /home/decision/inghui/~/mri_pipeline-master/mri_pipeline-master_inghui_101_001/
%
% Input: 
%       SUBJ_NR            ...unique participant number
%       SESSION_NR         ...
%


diary(['logs/data_quality_check' num2str(SUBJECT_NUMBER) '.log'])

% you can comment this assertion out, if you change the movie codec to
% 'Uncompressed AVI' or 'Motion JPEG AVI' below
assert(ispc,'You need to run this script from a Windows machine');

addpath('../utils')
addpath('/home/common/matlab/spm8');

% set default: session_number == 1
if ~exist('SESSION_NUMBER','var')
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
    nRuns = length(subjectParameter.runSeries);
    
    % define where to put output files
    folderOutput = fullfile(subjectParameter.subjectFolder, 'data_quality_checks');
    if ~exist(folderOutput, 'dir' ); mkdir(folderOutput); end % ensure the folder exists
    
    while workMissing
        switch checkpoint
            case 1
                %%%% checkpoint 1  - load image data into 4d array
                fprintf('Starting with checkpoint %i\n', checkpoint);
                
                for iRun=nRuns:-1:1
                    %- set settings for loading image data
                    %---------------------------------------
                    folderImages = sprintf('%s/run%i',subjectParameter.dataCombinedPath,iRun);
                    % file filter used by SPM - modify if you want to create videos from other images
                    fileFilter = '^crf\S*nii$'; % use ^crf to get combined, but otherwise untouched images (ie not 'preprocessed')
                    % whether SPM should decend into subfolders of 'folderImages' when looking for files
                    decendIntoSubfolders = false;
                    
                    %- run function
                    %-----------------
                    [data{iRun}, volumeInfo] = LoadImageData(folderImages, fileFilter, decendIntoSubfolders);
                end
                
                %- advance checkpoint
                %----------------------
                checkpoint = checkpoint + 1;
                
            case 2
                fprintf('Starting with checkpoint %i\n', checkpoint);
                %%% checkpoint 2 - Create Movies
                
                for iRun=1:nRuns
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
                    configMovie.movieFilenames{1} =sprintf('CheckMosaicMovie_default_%03d_%03d_run%i',SUBJECT_NUMBER,SESSION_NUMBER,iRun);
                    % define movie using percentiles below/above which to clip:
                    configMovie.clims{2}.type = 'percentile';
                    configMovie.clims{2}.value(1) = 0.002; % percentile below which to clip to black
                    configMovie.clims{2}.value(2) = 0.60; % percentile above which to clip to white
                    configMovie.movieFilenames{2} = sprintf('CheckMosaicMovie_contrast_%03d_%03d_run%i',SUBJECT_NUMBER,SESSION_NUMBER,iRun);
                    % which compression type VideoWriter will use
                    configMovie.compressionType = 'MPEG-4';
                    
                    %- run function
                    %-----------------
                    CreateMovie(configMovie, data{iRun});
                end
                %- advance checkpoint
                %----------------------
                checkpoint = checkpoint + 1;
                
            case 3
                fprintf('Starting with checkpoint %i\n', checkpoint);
                %%% checkpoint 3 - create plots of intensity data
                
                for iRun=1:nRuns
                    %- set setting for histrogram plot
                    %-----------------------------------
                    % create histogram of data
                    % Making a histogram of the data
                    nbins = 128;
                    titleString = sprintf('Histogram of subject %i - session %i - run %i', SUBJECT_NUMBER, SESSION_NUMBER,iRun);
                    filenameHistogram = fullfile(folderOutput, sprintf('Histogram_%03d_%03d_run%i.png', SUBJECT_NUMBER, SESSION_NUMBER,iRun) );
                    
                    %- run function
                    %-----------------
                    CreateHistogram(data{iRun},nbins,titleString,filenameHistogram)
                    
                    %- create signal intensity curves
                    % create intensity=f(time) plots
                    titleString = sprintf('Check: signal - subject %i (session %i) - run %i',SUBJECT_NUMBER, SESSION_NUMBER,iRun);
                    filenameSignal = fullfile(folderOutput, sprintf('SignalCheck_%03d_%03d_run%i.png', SUBJECT_NUMBER,SESSION_NUMBER,iRun));
                    %- run function
                    %-----------------
                    CreateMeanCurvePlot(data{iRun},titleString, filenameSignal);
                    
                end
                
                %- advance checkpoint
                %----------------------
                checkpoint = checkpoint + 1;
                
            case 4
                fprintf('Starting with checkpoint %i\n', checkpoint);
                %%% Checkpoint 4 - detect and optionally remove spikes

                %- set spike-script settings
                configSpike.spikeThreshold          = 0.3;                  % fractional deviation of slice mean that qualifies as a 'spike' 0.1 = 10%
                configSpike.mode                    = 'remove';              % mode: 'check' or 'remove'. Remove replaces affected volume by mean of the adjecent slices.
                configSpike.prefixSpike             = 'n';                   % if you want a prefix for your new images, please say so. Beware however, this might intervene with your original functional prefix!
                configSpike.maskType                = 'noise_corner';       % 'noise' makes mask from noise level, 'noise_corner' takes image corners, 'intensity' simple intensity mask
                configSpike.masknoise               = 2;                    % if mask_type 'noise': creates mask based on typical noise*cfg.masknoise
                configSpike.maskIntensity.int       = 0.3;                  % if mask_type 'intensity': creates mask based on intensity relative to volume mean: 1.0=mean of whole volume, 0.1=10% of mean
                configSpike.maskIntensity.fix       = ('yes');              % if mask_type 'intensity': 'yes' creates fixed mask from first 5 volumes, 'no' mask recalculation for each volume
                configSpike.maskIntensity.mode      = 'outside_brain';      % if mask_type 'intensity':'inside_brain' or 'outside_brain' spike-intensity detection
                configSpike.selectionMethod         = 'timecourseAverage';  % Select spikes based on 'timecouseAverage' or 'previousVolume;
                configSpike.spikeDir                = folderOutput;
                configSpike.runmode                 = ('check');

                checkpoint = checkpoint + 1;
                
            case 5
                
                fprintf('Starting with checkpoint %i\n', checkpoint);
                %%% Checkpoint 5 - detect and optionally remove spikes

                if strcmp('remove', configSpike.mode);
                    fprintf('Checking and removing spikes from images.\n');
                elseif strcmp('check', configSpike.mode);
                    fprintf('Checking for spikes in images.\n');
                else 
                    fprintf('Unidentified configSpike.mode.\n');
                end
              
                for iRun = 1:nRuns

                    % Create and save mask
                    [MASK, noise] = GetMask(data{iRun}, configSpike);
                    SaveMask(MASK,volumeInfo,configSpike,iRun);

                    % Determine demonstrate and save timecourse slice averages
                    [sliceAverages, newImgsInfo] = SliceAverageDuplicate(data{iRun}, volumeInfo, MASK, configSpike);
                    histogram = ShowSaveSliceAvg(sliceAverages, volumeInfo, configSpike, iRun);
                    set(histogram,'Color','w');
                    figureName = fullfile(folderOutput, sprintf('CheckSpike_run%i.png',iRun));
                    saveas(histogram, figureName,'png');

                    % Detect spikes and safe file
                    [affectedVolumeSlice, affectedVolumes] = DetectSpikes(sliceAverages, configSpike);
                    SaveSpikefile(affectedVolumeSlice, affectedVolumes, data{iRun}, configSpike, iRun);

                    % If spikes have been detected and we were in 'check' mode before: recall with remove flag
                    if ( ~isempty(find(affectedVolumeSlice ~= 0, 1))  && strcmp('remove', configSpike.mode) == 1 )

                        %Remove spikes and save new_imgs_headers adjusted data
                        RemoveSpikes(affectedVolumeSlice, newImgsInfo);
                    end

                    %Close slice averages image
                    close(histogram);

                end
                
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

diary off
end

