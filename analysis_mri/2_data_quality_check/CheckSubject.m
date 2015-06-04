function CheckSubject(subj_nr, session_nr)
diary(['data_quality_check' num2str(subj_nr) '.log'])

addpath('/home/common/matlab/spm5');

fprintf('CHECK-SUBJECT: starting checking subject %i data\n', subj_nr)

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


try
    while work_missing
        switch checkpoint
            case 1
                %%%% checkpoint 1
                % create folder structure, and move images into appropriate folders
                fprintf('Starting with checkpoint 1\n')
                
                % get folder of raw data and combined data
                [path_str,filename, extension] = fileparts(mfilename('fullpath'));
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
                
                % create INFO variable, used by data-quality scripts
                %- set subject/session specific variables
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
                
                
                %- set movie-script settings
                INFO.check.movie.which  = 'both';                           % Indicate which movies should be created ('default', 'contrast', 'both').
                INFO.check.movie.contrast  = 0.98;                             % If the 'contrast' movie is selected (see cfg.which): Contrast value of that movie. A value between -1 (lowest contrast) and 1 (highest contrast) with 0 to leave the image as it is. Set to 0.98 to see the noise clearly.
                INFO.check.movie.bright = 0.97;                             % If the 'contrast' movie is selected (see cfg.which): Brightness value of that movie. A value between -1 (very dark) and 1 (very bright) with 0 to leave the image as it is. Set to 0.97 to see the noise clearly.
                INFO.check.movie.nr_imgs = 1000;                             % The maximum number of images to be read-in at once by bch_check_movie. For a very high number, you run the risk of overloading your memory.
                INFO.check.movie.save_temp= 1;                                % Set to "1" if you want to save the movie during it's creation ("0" for not). This will get rid of possible memory problems, but slows down the calculations (especially if nr_imgs is low).
                INFO.check.movie.fps = 6;                                % Frames per second.
                INFO.check.movie.prefix = '';
                INFO.check.movie.flip	= defaults.analyze.flip;
                INFO.check.movie.ori     = 'hor';
                INFO.check.movie.noise_high  = 0.60;                             % percentile above which to clip to white
                INFO.check.movie.noise_low   = 0.002;                            % percentile below which to clip to black
                
                %- set spike-script settings
                INFO.check.spike.spike_threshold   = 0.3;                        % fractional deviation of slice mean that qualifies as a 'spike' 0.1 = 10%
                INFO.check.spike.mode        = 'check';                    % mode: 'check' or 'remove'
                INFO.check.spike.prefix      = '';                         % if you want a prefix for your new images, please say so. Beware however, this might intervene with your original functional prefix!
                INFO.check.spike.mask_type         = 'noise_corner';                 % 'noise' makes mask from noise level, 'noise_corner' takes image corners, 'intensity' simple intensity mask
                INFO.check.spike.masknoise         = 2;                              % if mask_type 'noise': creates mask based on typical noise*cfg.masknoise
                INFO.check.spike.maskint.int       = 0.3;                            % if mask_type 'intensity': creates mask based on intensity relative to volume mean: 1.0=mean of whole volume, 0.1=10% of mean
                INFO.check.spike.maskint.fix       = ('yes');                        % if mask_type 'intensity': 'yes' creates fixed mask from first 5 volumes, 'no' mask recalculation for each volume
                INFO.check.spike.maskint.mode      = 'outside_brain';                % if mask_type 'intensity':'inside_brain' or 'outside_brain' spike-intensity detection
                INFO.check.spike.base_cor_on       = 'timecourse_avg';
                INFO.check.spike.spike_dir = INFO.dir.output;
                
                checkpoint = 2;
            case 2 % create movie - runwise(percentiles)
                fprintf('Starting with checkpoint 2\n')
                fprintf('Creation of mosaic movie(s) initiated.\n');
                for iRun=1:nRuns
                    fprintf('Creating Movie \tRun: %i\n ',iRun);
                    
                    % define, and if necessary, create output folder
                    movie_dir = INFO.dir.output;
                    
                    % get list of images
                    filter_img = '^s\S*nii$';  % modify this to change the file filter
                    img_dir = fullfile(INFO.dirs.root,INFO.dirs.orig, ['run' int2str(iRun)] );
                    images = cellstr(spm_select('List',img_dir,filter_img));
                    imgs = cellstr(strcat(img_dir,filesep,images));
                    if isempty(imgs)
                        warning('CHECK_SUBJECT:FilesNotFound','No files that pass the image filter (%s) have been found.',filter_img);
                    end
                    
                    % check which which movies to create:
                    do_default = 0; do_contrast = 0;
                    if strcmpi(INFO.check.movie.which,'both') || strcmpi(INFO.check.movie.which,'default')
                        mov_default_name = fullfile(movie_dir,sprintf('CheckMosaicMovie_%s%s_default.avi',INFO.check.movie.prefix,INFO.runs{iRun}));
                        do_default = 1;
                    end
                    if strcmpi(INFO.check.movie.which,'both') || strcmpi(INFO.check.movie.which,'contrast') && ...
                            INFO.check.movie.contrast ~= 0 && INFO.check.movie.bright ~= 0
                        mov_contrast_name = fullfile(movie_dir,sprintf('CheckMosaicMovie_%s%s_contrast.avi',INFO.check.movie.prefix,INFO.runs{iRun}));
                        do_contrast = 1;
                    end
                    
                    % check whether to save temporary files
                    if INFO.check.movie.save_temp
                        temp_default_file = fullfile(movie_dir,sprintf('TempCheckMosaicMovie_%s%s_default.mat',INFO.check.movie.prefix,INFO.runs{iRun}));
                        temp_contrast_file = fullfile(movie_dir,sprintf('TempCheckMosaicMovie_%s%s_contrast.mat',INFO.check.movie.prefix,INFO.runs{iRun}));
                    end
                    
                    % limit how many images loaded into memory at one time
                    clear images;
                    n = length(imgs);
                    m = INFO.check.movie.nr_imgs;
                    i_on = 1;
                    i_off = n;
                    if n>m
                        i_off = [];
                        c = ceil(n/m);
                        for d = 1:c-1
                            i_on = [i_on floor(d*n/c)+1];
                            i_off = [i_off floor(d*n/c)];
                        end
                        i_off = [i_off n];
                    end
                    
                    % for all images being loaded now
                    for j = 1:length(i_on)
                        
                        % load images into memory
                        fprintf('Loading images (part %i/%i)...\n',j,length(i_on));
                        vols = spm_vol(imgs(i_on(j):i_off(j)));
                        if ~isstruct(vols(1))
                            for iVol = 1:length(vols)
                                tvols(iVol) = vols{iVol};
                            end
                            vols = tvols;
                        end
                        data = spm_read_vols(vols);
                        fprintf(' done');
                        clear vols;
                        clear tvols;
                        [dimx,dimy,nrslice,nrvols] = size(data);
                        
                        % setup mosaic parameters
                        mosaic_format   = ceil(sqrt(nrslice)); % nr of slices in each direction
                        mosaic_x        = mosaic_format * dimx;
                        mosaic_y        = mosaic_format * dimy; % size in pixels
                        mosaic          = zeros(mosaic_x, mosaic_y, nrvols);
                        text_x          = round(mosaic_x - dimx/4);
                        text_y          = round(mosaic_y - dimy/2);
                        
                        % create mosaic matrix
                        for vol = 1:nrvols
                            for slice = 1:nrslice
                                xmin = mod(slice - 1, mosaic_format) * dimx + 1;
                                xmax = xmin + dimx - 1;
                                ymin = (ceil(slice/mosaic_format)-1) * dimy + 1;
                                ymax = ymin + dimy - 1;
                                
                                slice_data = reshape(data(:,:,slice,vol), dimx, dimy);
                                slice_data = rot90(slice_data);
                                
                                if strcmp(INFO.check.movie.ori, 'vert')
                                    if INFO.check.movie.flip, mosaic(xmin:xmax, ymax:-1:ymin, vol) = slice_data;
                                    else     mosaic(xmin:xmax, ymin:ymax, vol)    = slice_data;
                                    end
                                elseif strcmp(INFO.check.movie.ori, 'hor')
                                    if INFO.check.movie.flip, mosaic(ymin:ymax, xmax:-1:xmin, vol) = slice_data;
                                    else     mosaic(ymin:ymax, xmin:xmax, vol)    = slice_data;
                                    end
                                end
                            end
                        end
                        clear data;
                        
                        % plot mosaic matrix
                        h = figure('NumberTitle','off');
                        imagesc(mosaic(:,:,1));
                        colormap(gray);
                        axis tight
                        set(gca,'nextplot','replacechildren');
                        
                        if do_default % Add the frames to the movie - default
                            fprintf('Creating default movie...\n');
                            set(h,'Name',['CheckMosaicMovie_' INFO.runs{iRun} '_default']);
                            % load previous mosaic data (trying to limit
                            % memory usage by saving to temp-file)
                            if INFO.check.movie.save_temp && j>1; load(temp_default_file); end;
                            
                            % plot frames
                            mmin = min(mosaic(:));
                            mmax = max(mosaic(:));
                            for k = 1:size(mosaic,3)
                                idx = i_on(j)+k-1;
                                imagesc(mosaic(:,:,k), [mmin, mmin + (mmax-mmin)/INFO.check.movie.bright]);
                                hold on;
                                if mosaic(text_x,text_y,k) < mean(mean(mosaic(:,:,k)))
                                    text(text_x,text_y,num2str(idx),'Color','w','FontSize',24,'HorizontalAlignment','right');
                                else
                                    text(text_x,text_y,num2str(idx),'Color','k','FontSize',24,'HorizontalAlignment','right');
                                end
                                hold off;
                                mov_default(idx) = getframe;
                            end
                            if INFO.check.movie.save_temp; save(temp_default_file,'mov_default'); clear mov_default; end;
                            fprintf(' done');
                        end
                        
                        
                        
                        if do_contrast % Add the frames to the movie - contrast
                            fprintf('Creating contrast movie...\n');
                            set(h,'Name',['CheckMosaicMovie_' INFO.runs{iRun} '_contrast']);
                            
                            % load previously loaded data
                            if INFO.check.movie.save_temp && j>1; load(temp_contrast_file); end;
                            
                            % set thresholds
                            thr_low = prctile(mosaic(:)/18.84, INFO.check.movie.noise_low*100);
                            thr_high = prctile(mosaic(:)/18.84, INFO.check.movie.noise_high*100);
                            
                            
                            for k = 1:size(mosaic,3)
                                img = mosaic(:,:,k);
                                img = ((img./1884).*100);
                                lev = 1;
                                clims = [thr_low thr_high];
                                idx = i_on(j)+k-1;
                                imagesc(img,clims);
                                hold on;
                                if mosaic(text_x,text_y,k) < lev
                                    text(text_x,text_y,num2str(idx),'Color','w','FontSize',24,'HorizontalAlignment','right');
                                else
                                    text(text_x,text_y,num2str(idx),'Color','k','FontSize',24,'HorizontalAlignment','right');
                                end
                                hold off;
                                mov_contrast(idx) = getframe;
                            end
                            if INFO.check.movie.save_temp; save(temp_contrast_file,'mov_contrast'); clear mov_contrast; end;
                            fprintf(' done');
                        end
                        
                        close(h);
                        
                        % Making a histogram of the data
                        f = figure;
                        hist(mosaic(:)/18.84,128);
                        str = sprintf('Histogram of subject %i - session %i - run %i', subj_nr , session_nr ,iRun);
                        title(str)
                        xlabel('Value of intensity')
                        ylabel('Pixel count')
                        figname = fullfile(movie_dir, [sprintf('Histogram_%i_%i_%i', subj_nr , session_nr ,iRun) '.png' ]);
                        saveas(f, figname)
                        close(f)
                        clear mosaic;
                        
                    end % loop over temporary files/loading images in batches
                    
                    if do_default
                        fprintf('Saving movie - default...');
                        if INFO.check.movie.save_temp; load(temp_default_file); end;
                        movie2avi(mov_default,mov_default_name,'fps',INFO.check.movie.fps);
                        if INFO.check.movie.save_temp; delete(temp_default_file); end;
                        clear mov_default;
                        fprintf(' done\n');
                    end
                    
                    if do_contrast
                        fprintf('Saving movie - contrast...');
                        if INFO.check.movie.save_temp; load(temp_contrast_file); end;
                        %movie(mov_contrast,1,cfg.fps)  % Play the contrast movie one time
                        movie2avi(mov_contrast,mov_contrast_name,'fps',INFO.check.movie.fps);
                        if INFO.check.movie.save_temp; delete(temp_contrast_file); end;
                        clear mov_contrast;
                        fprintf(' done\n');
                    end
                    
                    checkpoint = 3;
                end
            case 3 % create intensity=f(time) plots
                fprintf('checkpoint 3 reached - creating signal plot\n')
                
                for iRun = 1:length(INFO.runs)
                    
                    % define and make sure we have output folder
                    signal_dir = INFO.dir.output;
                    
                    % get list of all images
                    filter_img = '^s\S*nii$';
                    img_dir = fullfile(INFO.dirs.root, INFO.dirs.orig, ['run' int2str(iRun)] );
                    images = cellstr(spm_select('List',img_dir,filter_img));
                    imgs = cellstr(strcat(img_dir,filesep,images));
                    if isempty(imgs)
                        warning('CHECK_SUBJECT:FilesNotFound','No files that pass the image filter (%s) have been found.',filter_img);
                    end
                    
                    % calculate signal
                    [slicesig,globalsig] = calc_sig(imgs);
                    
                    % save signal to .mat file
                    save(fullfile(signal_dir,sprintf('CheckSignal_run%i.mat',iRun)),'*sig');
                    
                    % create plot
                    str = sprintf('CheckSignal_subject%i_session%i_run%i',subj_nr,session_nr, iRun);
                    h = figure('Name',str,'NumberTitle','off');
                    set(h,'Color','w');
                    subplot(2,2,1); plot(slicesig);
                    title_str = sprintf('Stab check: subject %i - session %i - run %i',subj_nr, session_nr,iRun);
                    title(['Slice Sig ' title_str]);
                    subplot(2,2,3); plot(var(slicesig));
                    title('Variance:');
                    subplot(2,2,2); plot(globalsig);
                    title(['Glob Sig ' title_str]);
                    subplot(2,2,4); bar(var(globalsig));
                    title('Variance:');
                    
                    figname = fullfile(signal_dir,sprintf('CheckSignal_subject%i_session%i_run%i.png',subj_nr,session_nr,iRun));
                    saveas(h, figname,'png');
                    close(h);
                end
                
                checkpoint = 4;
                
            case 4 % create spike plot
                fprintf('checkpoint 4 reached -- creating spike plot')
                if strcmp('remove', INFO.check.spike.mode);
                    fprintf('Checking and removing spikes from images.\n');
                end
                if strcmp('check', INFO.check.spike.mode);
                    fprintf('Checking for spikes in images.\n');
                end
                
                for iRun = 1:length(INFO.runs)
                    
                    % get list of all images
                    filter_img = '^s\S*nii$';
                    img_dir = fullfile(INFO.dirs.root, INFO.dirs.orig, ['run' int2str(iRun)] );
                    images = cellstr(spm_select('List',img_dir,filter_img));
                    imgs = cellstr(strcat(img_dir,filesep,images));
                    if isempty(imgs)
                        warning('CHECK_SUBJECT:FilesNotFound','No files that pass the image filter (%s) have been found.',filter_img);
                    end
                    
                    % load images
                    fprintf('Loading images - run %i...', iRun);
                    V = spm_vol(imgs);
                    fprintf(' done\n');
                    
                    %create and save mask
                    [mask, noise] = getmask(V, INFO.check.spike);
                    save_mask(mask,V,INFO.check.spike,iRun);
                    
                    % determine timecourse slice averages
                    INFO.check.spike.runmode = ('check');
                    [slice_averages, new_imgs_headers] = slcavg_dupl(V, mask, noise, INFO.check.spike);
                    h = show_save_slice_avg(slice_averages, V, INFO.check.spike,iRun);
                    set(h,'Color','w');
                    figname = fullfile(INFO.dir.output, sprintf('CheckSpike_run%i.png',iRun));
                    saveas(h, figname,'png');
                    
                    % detect spikes
                    [affected_vol_slc, affected_vol] = detect_spikes(slice_averages, INFO.check.spike);
                    save_spikefile(affected_vol_slc,affected_vol,V,INFO.check.spike,iRun);
                    
                    % if spikes have been detected and we were in 'check' mode before: recall with remove flag
                    if ( ~isempty(find(affected_vol_slc ~= 0, 1))  && strcmp('remove', INFO.check.spike.mode) == 1 )
                        INFO.check.spike.runmode = ('remove');
                        [slice_averages, new_imgs_headers] = slcavg_dupl(V, mask, noise, INFO.check.spike);
                        %remove spikes
                        remove_spikes(affected_vol_slc, new_imgs_headers);
                    end
                    
                    close(h);
                    
                end
                
                work_missing = 0;
        end
    end
    
    fprintf('\n\nChechking subject %i finished\n\n',subj_nr);

    % if reaching this point, we're done. Thus delete the checkpoint
    if exist(checkpoint_filename,'file')
        delete(checkpoint_filename)
    end
    
catch err
    save(checkpoint_filename)
    rethrow(err);    
end


end

