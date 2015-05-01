classdef CombineEcho < handle
    %CombineEcho Combines mutli-echo data using PAID weighting
    % 
    %   for detailed description, see wiki on github
    % 
    %   Importantly, this is a handle-class, and not a value class; 
    % this changes the default, see for more details: 
    % http://stackoverflow.com/questions/8086765/why-do-properties-not-take-on-a-new-value-from-class-method 
    % 
    % Usage: 
    %   combiner = CombineEcho( 'filenames',cell_array_of_files,...
    %                           'nEchoes', [4 4 4],...
    %                           'TE',cell_array_of_TE,...
    %                           'outputDir','/path/to/output/directory');
    %   combiner.DoMagic(); % runs all steps
    % 

    properties
        % Cell arrays; each cell contains filenames of original Nifti files of ONE run, ONE echoe
        % this should have all files, including the prescans -- we assume the first nWeightVolumes in each run/echo are the pre
        % Note: filenames MUST include full path info, that is also the '/home/username/projects/subject1/..' for each file
        filenames; % size: {nRuns, max(nEchoes)}

        % array of integers - Number of Echoes - should be array of length = nRuns,e.g. [4 4 4]
        nEchoes; % size: [nRuns]

        % cell array (length=nRun) of echo times
        % each cell contains an array of echo times for that run
        TE; % size: {nRuns}
        
        % Where should the combined files be saved in
        outputDir;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% BELOW: These properties should only be set manually if going against our group's default
        
        %Number of Volumes used for calculating weights
        nWeightVolumes=30;
      
        % per default, only final output will be copied to the 'outputDir'
        keepIntermediaryFiles = false;

        % combining weights - cell array
        weights; 
    end

    methods
        
        function self=CombineEcho(varargin)
        % ------------------------------------------------------------------
        % 
        % Constructor - CombineEcho
        % 
        % ------------------------------------------------------------------
            % Read arguments
            for i = 1:2:length(varargin)
                if ismember(varargin{i},fieldnames(self))
                   self.(varargin{i}) = varargin{i+1};
                else
                    warning('Unrecognized option: %s.',varargin{i});
                end
            end
        end

        function DoMagic(self)
        % ------------------------------------------------------------------
        % 
        % Run all combining sub-parts in one go
        % 
        % ------------------------------------------------------------------
            fprintf('Combiner doing its magic\n');
            self.AssertReadyToGo();
            % self.SpikeDetection(); % not implemented yet
            self.Realign();
            self.SplitRealignmentParameters();
            self.Reslice();
            self.CalculateWeights();
            self.ApplyWeights();
        end

        function AssertReadyToGo(self)
        % ------------------------------------------------------------------
        % 
        % Assert that all ready to do magic, e.g. all variables set
        % 
        % ------------------------------------------------------------------
            % test whether all public properties non-empty
           % exception: weights - will be set by CalculateWeights()
            ignoreProperties = {'weights'};
            allProperties = fieldnames(self);
            checkProperties = setxor(allProperties,ignoreProperties); % all except the ones on the ingore list
            msg = ''; e = false;
            for i = 1:length(checkProperties)
                if isempty(self.(checkProperties{i}))
                    msg = [msg checkProperties{i} ' is empty. You must set this property to use ' class(self) '\n'];
                    e = true;
                end
            end
            assert(~e,msg);
        end

        function SpikeDetection(self)
        % ------------------------------------------------------------------
        % 
        % Check spikes before doing anything
        % 
        % ------------------------------------------------------------------
            %%% TODO: add spike detection
            fprintf('CombineEchoe: spike detection not yet implemented\n');
        end

        


        function Realign(self)
        % ------------------------------------------------------------------
        % 
        % Realign all images, of all runs, to the grand mean image
        % 
        % ------------------------------------------------------------------
        % Images are realigned to the overall mean image of the first echo, 
        % across all runs. Then, these realignments are applied to all the 
        % other echoes.
            t=tic;
            
            % concatenate all runs, so we can realign volumes of first echo in one go
            files = self.ConcatRuns();

            % % first realign first echo:
            % this also creates a single rp_*.txt file in the folder of the first run
            flags.rtm = 1; % use 2-pass procedure
            spm_realign(files(:,:,1),flags);

            
            % % Transformation matrices of all volumes of all echoes
            % % (except first echo) are changed to the matrix of first echo,
            % % thus, realigned.
            
            for i=1:size(files,1) % 1:nFiles
                % load voxel-to-world mapping from realigned, first echo
                V = spm_get_space(files(i,:,1)); 
                for j=2:size(files,3) % 1:nEchoes
                    % realigned by applying voxel-to-world mapping from first echo
                    % TODO: add check for files(i,:,j) not being empty -- spm_get_space will through an error about hdr if it is..
                    % this can esp. happen if one run has fewer/more echoes than the other runs (e.g. because resting state) 
                    spm_get_space(files(i,:,j),V);
                end
            end

            fprintf('Realignment done in:\n');  
            toc(t)
        end

        function SplitRealignmentParameters(self)
        % ------------------------------------------------------------------
        % 
        % When realigning all runs in one go, only one rp_*.txt file is
        % written. This function splits it into to appropriate number of files
        % 
        % ------------------------------------------------------------------
            nRuns = size(self.filenames,1);

            % first, make backup copy of rp_*.txt file
            unix(sprintf('mv %s/rp_f*.txt %s/rp_allRuns.txt',self.outputDir,self.outputDir));

            % open file with all parameters
            fileAll = sprintf('%s/rp_allRuns.txt',self.outputDir);
            f_orig  = fopen(fileAll,'r');

            for iRun=1:nRuns
                % open output file for current run
                fileOut = sprintf('%s/rp_run%i.txt',self.outputDir,iRun);
                f_out = fopen(fileOut,'w');

                % determine length of current run
                nLinesToCopy = size(self.filenames{iRun,1},1); 

                % get nLinesToCopy and write the to f_out file
                for i=1:nLinesToCopy
                    textline = fgetl(f_orig); % this automatically starts off from last position
                    fprintf(f_out, '%s\n', textline);
                end

                % close file with extracted lines
                fclose(f_out);
            end
            fclose(f_orig);
        end


        function Reslice(self)
        % ------------------------------------------------------------------
        % 
        % Reslice all images, using SPM12 reslize function
        % 
        % ------------------------------------------------------------------
            t=tic;

            files = self.ConcatAll();

            spm_reslice(files);
            
            fprintf('Reslicing is finished in:\n');
            toc(t)
        end

        function CalculateWeights(self)
        % ------------------------------------------------------------------
        % 
        % Calculates weights for each run independently
        % 
        % ------------------------------------------------------------------
            t = tic;
            % get list of all prescans
            % get first nWeightVolumes from each run and echo, and prepend an 'r' for spm-resliced
            nRuns = size(self.filenames,1);
            for iRun=1:nRuns
                clear filesEcho;
                for iEcho=1:self.nEchoes(iRun)
                    filesTemp=self.filenames{iRun,iEcho};    
                    charTemp = cell2mat(filesTemp(1:self.nWeightVolumes,:));                    
                    filesEcho(:,:,iEcho) = self.AddPrefix(charTemp,'r');
                end
                filesAllRuns{iRun} = filesEcho;
            end

            % calculate weights for each run independently
            for iRun = 1:nRuns
                files = filesAllRuns{iRun};
                
                % use first image to initialize SPM volume object and 4D array
                dimVolume = spm_vol(files(1,:,1)); 
                dim = dimVolume.dim;
                volume4D = zeros(dim(1),dim(2),dim(3),self.nWeightVolumes,self.nEchoes(iRun));

                % get timeseries of prescans
                for iVol=1:self.nWeightVolumes
                    for iEcho=1:self.nEchoes(iRun)
                        V = spm_vol(files(iVol,:,iEcho));
                        volume4D(:,:,:,iVol,iEcho) = spm_read_vols(V);
                    end
                end

                % calculate weights based on tSNR of prescan timeseries(c.f. Poser et al., (2006).
                % doi:10.1002/mrm.20900)
                tSNR = zeros(dim(1),dim(2),dim(3),self.nEchoes(iRun));
                CNR = zeros(dim(1),dim(2),dim(3),self.nEchoes(iRun));
                weight = zeros(dim(1),dim(2),dim(3),self.nEchoes(iRun));
                TE = self.TE{iRun};
                for j=1:self.nEchoes(iRun)
                    tSNR(:,:,:,j) = mean(volume4D(:,:,:,:,j),4)./std(volume4D(:,:,:,:,j),0,4);
                    CNR(:,:,:,j) = tSNR(:,:,:,j) * TE(j);
                end
                CNRTotal = sum(CNR,4);
                for i=1:self.nEchoes(iRun)
                    weight(:,:,:,i) = CNR(:,:,:,i) ./ CNRTotal;
                end
                self.weights{iRun} = weight;
            end 

            fprintf('Weight Calculation finished in:\n');
            toc(t);
        end

        function ApplyWeights(self)
        % ------------------------------------------------------------------
        % 
        % Apply weights to all images, including prescans
        % 
        % ------------------------------------------------------------------
            t=tic;
            try 
                % combine echos of all functional images using weights calculated based on
                % prescans
                clear V; % delete previously used 'V' variable..

                nRuns = size(self.filenames,1);

                for iRun = nRuns:-1:1
                    % grab weights for current run
                    weight=self.weights{iRun};

                    % get the resliced nifti images of current run
                    files = self.AddPrefix(self.FilesOfRun(iRun),'r');

                    % use first image to initialize V-variable
                    dimVolume = spm_vol(files(1,:,1)); 
                    dim = dimVolume.dim;

                    % loop over all timepoints (ie files in one echo)
                    for iVolume = 1:size(files,1)
                        % grab all volumes of same timepoint
                        for j=1:self.nEchoes(iRun)
                            V{j} = spm_vol(files(iVolume,:,j));
                        end

                        % create new volume variable
                        newVolume = V{1};
                        % follow SPM convention to prefix with single letter to indicate preprocessing step
                        newVolume.fname = self.AddPrefix(newVolume.fname, 'c');
                        newVolume.descrip = 'PAID combined'; % update description

                        % combine echoes of current timepoint
                        I_weighted = zeros(newVolume.dim);
                        % Initilize 4d array 
                        I = zeros(dim(1),dim(2),dim(3),self.nEchoes(iRun));

                        for j=1:self.nEchoes(iRun)
                            I(:,:,:,j) = spm_read_vols(V{j});
                            I_weighted = I_weighted + I(:,:,:,j).*weight(:,:,:,j);
                        end

                        % write new volume to disk
                        spm_create_vol(newVolume);
                        spm_write_vol(newVolume,I_weighted);
                    end
                end

                fprintf('Weights applied to all images in:\n');
                toc(t)
            catch errId
               disp(errId)
            end
        end

    end

    methods(Access=private)
        function files=FilesOfRun(self,iRun)
        % ------------------------------------------------------------------
        % 
        % Return all files of a run as a 3-dim char-matrix
        % 
        % ------------------------------------------------------------------
        % this returns a 3-dim char-matrix, with
        % dim(1) = nr of files
        % dim(2) = chars of filenames
        % dim(3) = echoes

            % initialize char-matrix
            [nFiles nChars] = size(cell2mat(self.filenames{iRun,1}));
            files = char(zeros(nFiles,nChars,self.nEchoes(iRun)));

            % and copy content to output matrix
            for iEcho=1:self.nEchoes(iRun)
                files(:,:,iEcho)= char(cell2mat(self.filenames{iRun,iEcho}));
            end
            
        end

        function out = ConcatRuns(self)
        % ------------------------------------------------------------------
        % 
        % Return a CharMatrix of files, sorted by echo
        % 
        % ------------------------------------------------------------------
        % this returns a 3-dim char-matrix, with
        % dim(1) = nr of files
        % dim(2) = chars of filenames
        % dim(3) = echoes
        % Importantly, all runs are concatenated on dim(1) (ie images are just
        % listed one after the other - but still sorted by echo)

            % collect all sizes of the entries of cell-array
            for iRun=size(self.filenames,1):-1:1
                for iEcho=self.nEchoes(iRun):-1:1
                    [nFiles(iRun,iEcho) nChars(iRun,iEcho)] = size(cell2mat(self.filenames{iRun,iEcho}));
                end
            end

            % pick largest entry dimensions for output matrix, and preallocate
            out = char(zeros(max(sum(nFiles,1)),max(max(nChars)),max(self.nEchoes)));

            % and copy content to output matrix
            for iEcho=1:self.nEchoes(iRun)
                offset = 0;
                for iRun=1:size(self.filenames,1)
                    out((offset+1):(offset+nFiles(iRun,iEcho)),1:nChars(iRun,iEcho),iEcho)= char(cell2mat(self.filenames{iRun,iEcho}));
                    offset = offset + nFiles(iRun,iEcho);
                end
            end
        end

        function out = ConcatAll(self)
        % ------------------------------------------------------------------
        % 
        % return a char-matrix, where each line is an image, with all images
        % concatenated
        % 
        % ------------------------------------------------------------------
            files = self.ConcatRuns();
            nEchoes = size(files,3);
            offset = 0;
            for iEcho = 1:nEchoes
                % TODO: make sure no empty lines are added
                nFiles = length(files(:,1,iEcho));
                out((offset+1):(offset+nFiles),:) = files(:,:,iEcho);
                offset = offset + nFiles;
            end
        end

        function out = AddPrefix(self, files, prefix)
        % ------------------------------------------------------------------
        % 
        % take 1-, 2- or 3-dim matrix of files, and add prefix to them. This 
        % assumes that each line in 'files' is a fullpath-filename, and we
        % need to add prefix to the filename, without changing the fullpath
        % 
        % ------------------------------------------------------------------
            if (ndims(files)==1)
                out = char(zeros(length(files)+1));
                [pathstr, name, ext] = fileparts(files);
                out = char([pathstr '/' prefix name ext]);
                
            elseif (ndims(files)==2)
                out = char(zeros(size(files,1),size(files,2)+1));
                for i=1:size(files,1)
                    [pathstr, name, ext] = fileparts(files(i,:));
                    out(i,:) = char([pathstr '/' prefix name ext]);
                end

            elseif (ndims(files)==3)
                out = char(zeros(size(files,1),size(files,2)+1,size(files,3)));
                
                for i=1:size(files,1)
                    for j=1:size(files,3)
                        [pathstr, name, ext] = fileparts(files(i,:,j));
                        out(i,:,j) = char([pathstr '/' prefix name ext]);
                    end
                end
            else
                error('Wrong usage of AddPrefix(..) function. files must be a one, two or three dimensional char-matrix');
            end
        end
    end
end

