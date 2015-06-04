function CheckSubject(subj_nr, session_nr)
%
% Checks combined fMRI data per subject on spikes.
% Select a small chunk of data by use of a mask to check it on spikes. A
% spike is defined by a datapoint that is larger than 30% lager than average
% slices.
%
% Input: subj_nr
% data should be nested as: /home/decision/inghui/~/mri_pipeline-master/mri_pipeline-master_inghui_101_001/
%

    %%           Prepare spike check: start afresh or continue           %%

    %Print message on screen
    fprintf('========================================================\n');
    fprintf('========================================================\n');
    fprintf('%s - Starting spike detection script for subject %i\n',datestr(now),subj_nr);
    fprintf('========================================================\n');

    %Create diary
    diary(['data_quality_check' num2str(subj_nr) '.log'])

    %Add path
    addpath('/home/common/matlab/spm8');
    addpath(pwd);

    % set default: session_number == 1
    if ~exist('session_id','var')
        session_nr=1;
    end

    % load potentially existing checkpoint-file
    checkpoint_filename = [pwd '/checkpoint_' num2str(subj_nr,'%03d') '_' num2str(session_nr,'%03d'),'.mat'];
    if exist(checkpoint_filename,'file')
        fprintf('loading previous data\n')
        load(checkpoint_filename);
    end

    if ~exist('checkpoint','var')
        fprintf('no checkpoint variable defined - starting from step 1\n')
        checkpoint = 1;
        work_missing = 1;
    end


    %%              Start spike detection structure

    try
        while work_missing
            switch checkpoint

                case 1
                    %% Checkpoint 1: Create folder structure and INFO variable

                    %%              Create folder structure

                    %Print message on screen
                    fprintf('Starting with checkpoint 1\n')
                
                    % get folder of raw data and combined data
                    [path_str,~, ~] = fileparts(mfilename('fullpath'));
                    pathParts = strsplit(path_str,'/');
                    project_folder = sprintf('%s/',pathParts{1:end-2});  % has trailing '/'
                    project_number = pathParts{end-2};
                    [~, user_name] = system('whoami'); user_name=user_name(1:end-1); % username contains trailing \n
                    subject_folder=[project_folder project_number '_' user_name '_' num2str(subj_nr,'%03d') '_' num2str(session_nr,'%03d') '/'];
                    folder_data_raw=[subject_folder 'data_raw'];
                    folder_data_combined=[subject_folder 'data_combined'];

                    % load meta-data, defined in /data_raw/scan_metadata.m
                    subject_settings_file = [folder_data_raw '/scans_metadata.m'];
                    if exist(subject_settings_file,'file')
                        run(subject_settings_file);
                    else
                        error('CHECK_SUBJECT:FileNotFound','Error loading subject-specific settings file. File "%s" not found',subject_settings_file);
                    end

                    nRuns = length(runSeries);

                    %% Create INFO variable, used by data-quality scripts

                    % set subject/session specific variables
                    INFO.subjects = subj_nr; % = {'502'};              % loop over subjects: subject is appended after root directory
                    for iRun=1:nRuns
                        INFO.runs{iRun} = sprintf('run%i',iRun);
                    end

                    INFO.dirs.root = folder_data_combined;
                    INFO.dirs.orig  = 'functional';       % directory with the original images, these stay untouched and are copied to the working directory before the preprocessing

                    % load spm-defaults;
                    global defaults;
                    if isempty(defaults) || ~isfield(defaults,'analyze') ||...
                            ~isfield(defaults.analyze,'flip')
                        defaults.analyze.flip = 0;
                    end
                    spm_defaults;               

                    % define where to put output files
                    INFO.dir.output = fullfile(INFO.dirs.root, 'data_quality_checks');
                    if ~exist(INFO.dir.output, 'dir' ); mkdir(INFO.dir.output); end % ensure the folder exists               

    %                 %- set movie-script settings
    %                 INFO.check.movie.which  = 'both';                         % Indicate which movies should be created ('default', 'contrast', 'both').
    %                 INFO.check.movie.contrast  = 0.98;                        % If the 'contrast' movie is selected (see cfg.which): Contrast value of that movie. A value between -1 (lowest contrast) and 1 (highest contrast) with 0 to leave the image as it is. Set to 0.98 to see the noise clearly.
    %                 INFO.check.movie.bright = 0.97;                           % If the 'contrast' movie is selected (see cfg.which): Brightness value of that movie. A value between -1 (very dark) and 1 (very bright) with 0 to leave the image as it is. Set to 0.97 to see the noise clearly.
    %                 INFO.check.movie.nr_imgs = 1000;                          % The maximum number of images to be read-in at once by bch_check_movie. For a very high number, you run the risk of overloading your memory.
    %                 INFO.check.movie.save_temp= 1;                            % Set to "1" if you want to save the movie during it's creation ("0" for not). This will get rid of possible memory problems, but slows down the calculations (especially if nr_imgs is low).
    %                 INFO.check.movie.fps = 6;                                 % Frames per second.
    %                 INFO.check.movie.prefix = '';
    %                 INFO.check.movie.flip	= defaults.analyze.flip;
    %                 INFO.check.movie.ori     = 'hor';
    %                 INFO.check.movie.noise_high  = 0.60;                      % percentile above which to clip to white
    %                 INFO.check.movie.noise_low   = 0.002;                     % percentile below which to clip to black

                    %- set spike-script settings
                    INFO.check.spike.spike_threshold   = 0.3;                  % fractional deviation of slice mean that qualifies as a 'spike' 0.1 = 10%
                    INFO.check.spike.mode              = 'remove';              % mode: 'check' or 'remove'. Remove replaces affected volume by mean of the adjecent slices.
                    INFO.check.spike.prefix_spike      = 'n';                   % if you want a prefix for your new images, please say so. Beware however, this might intervene with your original functional prefix!
                    INFO.check.spike.mask_type         = 'noise_corner';       % 'noise' makes mask from noise level, 'noise_corner' takes image corners, 'intensity' simple intensity mask
                    INFO.check.spike.masknoise         = 2;                    % if mask_type 'noise': creates mask based on typical noise*cfg.masknoise
                    INFO.check.spike.maskint.int       = 0.3;                  % if mask_type 'intensity': creates mask based on intensity relative to volume mean: 1.0=mean of whole volume, 0.1=10% of mean
                    INFO.check.spike.maskint.fix       = ('yes');              % if mask_type 'intensity': 'yes' creates fixed mask from first 5 volumes, 'no' mask recalculation for each volume
                    INFO.check.spike.maskint.mode      = 'outside_brain';      % if mask_type 'intensity':'inside_brain' or 'outside_brain' spike-intensity detection
                    INFO.check.spike.base_cor_on       = 'timecourse_avg';
                    INFO.check.spike.spike_dir         = INFO.dir.output;
                    INFO.check.spike.runmode           = ('check');

                    checkpoint = 2;
                
                case 2
                    %% Checkpoint 2: Detect spikes

                    %Print messages on screen
                    fprintf('checkpoint 4 reached -- creating spike plot.\n')

                    if strcmp('remove', INFO.check.spike.mode);
                        fprintf('Checking and removing spikes from images.\n');
                    elseif strcmp('check', INFO.check.spike.mode);
                        fprintf('Checking for spikes in images.\n');
                    else 
                        fprintf('Unidentified INFO.check.spike.mode.\n');
                    end

                    % Detect spikes per run                
                    for iRun = 1:length(INFO.runs)

                        % get list of all images
                        filter_img = '^s\S*nii$';
                        img_dir = fullfile(INFO.dirs.root, INFO.dirs.orig, ['run' int2str(iRun)] );
                        images = cellstr(spm_select('List',img_dir,filter_img));
                        imgs = cellstr(strcat(img_dir,filesep,images));

                        if isempty(imgs)
                            warning('CHECK_SUBJECT:FilesNotFound','No files that pass the image filter (%s) have been found.',filter_img);
                        end
                    
                        % Load images
                        fprintf('Loading images - run %i...', iRun);
                        V = spm_vol(imgs);
                        fprintf(' done\n');

                        % Create and save mask
                        [mask, noise] = getmask(V, INFO.check.spike);
                        save_mask(mask,V,INFO.check.spike,iRun);

                        % Determine and demonstrate timecourse slice averages
                        [slice_averages, new_imgs_headers] = slcavg_dupl(V, mask, INFO.check.spike);
                                      
                        h = show_save_slice_avg(slice_averages, V, INFO.check.spike,iRun);
                        set(h,'Color','w');
                        figname = fullfile(INFO.dir.output, sprintf('CheckSpike_run%i.png',iRun));
                        saveas(h, figname,'png');

                        % Detect spikes
                        [affected_vol_slc, affected_vol] = detect_spikes(slice_averages, INFO.check.spike);
                        save_spikefile(affected_vol_slc,affected_vol,V,INFO.check.spike,iRun);

                        % If spikes have been detected and we were in 'check' mode before: recall with remove flag
                        if ( ~isempty(find(affected_vol_slc ~= 0, 1))  && strcmp('remove', INFO.check.spike.mode) == 1 )

                            %Remove spikes and save new_imgs_headers adjusted data
                            remove_spikes(affected_vol_slc, new_imgs_headers);
                        end

                        %Close slice averages image
                        close(h);

                    end

                    checkpoint = 3;

                case 3
                    %% Finished!

                    work_missing = 0;
                    fprintf('Finished spike checks pp: %i\n', subj_nr)
            end
        end
    catch me
        me.message
        me.stack.line
    end
end

