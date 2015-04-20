classdef CombineWrapper < handle
    %CombineWrapper Combines mutli-echo data using PAID weighting
    % 
    %   for detailed description, see wiki on github
    % 
    %   Importantly, this is a handle-class, and not a value class; 
    % this changes the default behaviour (eg. copying the object), see for more details: 
    % http://stackoverflow.comn/questions/8086765/why-do-properties-not-take-on-a-new-value-from-class-method 
    % 
    % Example usage: 
    %   combiner = CombineWrapper('dataDir','/path/to/raw/data','runSeries',[7 11 15],'nEchoes',4,'scannerName','Skyra');
    %   combiner.DoMagic(); % runs all steps
    % 
    
    properties
        %Series corresponding to first echo of each run
        % The series numbers of where each run starts. This should be
        % consistent with expArray
        runSeries;
        
        %Number of Echoes - should be array of length=nRuns, e.g. [4 4 4] if having three runs
        % but can also be provided as a scalar (e.g. 4), assuming that all runs have same number of echoes
        nEchoes;
        
        % The following is used to identify all dicom files, coming from a
        % scanner.
        % Valid options: {'Skyra','Avanto','Trio'}
        % pick the one applying by setting the index
        scannerName;
        
        % raw data folder
        dataDir;

        % output folder - where combined data should be written to
        outputDir; % if not set, will be in a parallel folder to the raw data, ie '../data_combined' relative to 

        % working folder - all temporary files will be written there
        workingDir;

        % combiner - class CombineEcho instance
        % this can be used to call sub-steps of the combineEcho instance manually via the wrapper instance
        combiner;
    end

    properties(Access=protected)
        % These variables will be set during the running of the main Run()-function

        % cell array - holds ALL filenames, split by runs 
        filenamesDicom = {}; 

        % cell array - holds ONLY PRESCANs filenames. 
        % Note: these should also be part of the 'filenamesDicom'
        filenamesPrescanDicom = {};
    end
    
    methods
        
        function self=CombineWrapper(varargin)
        % ------------------------------------------------------------------
        % 
        % Construction - CombineWrapper
        % 
        % ------------------------------------------------------------------
        
            % Read optional arguments
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
        % run all combining sub-parts in one go
        % 
        % ------------------------------------------------------------------
            fprintf('Wrapper doing its magic\n');
            self.AssertReadyToGo();
            self.LoadAllDicoms();
            self.CreateCombiner();
            self.RunCombining();
        end

        function AssertReadyToGo(self)
        % ------------------------------------------------------------------
        % 
        % Assert all necessary properties are set
        % 
        % ------------------------------------------------------------------
            if isempty(self.outputDir)
                self.outputDir = [self.dataDir '/../data_combined'];
            end

            % test whether all public properties non-empty
            % exception: combiner instance - this will be set using all the other properties
            ignoreProperties = {'combiner'};
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

        function LoadAllDicoms(self)
        % ------------------------------------------------------------------
        % 
        % Based on assumed folder structure, fill up filenamesDicom
        % 
        % ------------------------------------------------------------------
        % using this public method to NOT expose the two underlying function 
        % to avoid forgetting the second one when not using 'DoMagic' interface
            % load ALL dicoms related to specified runSeries numbers
            self.GetAllDicomNames(); 

            % enforce that all echoes have the same number of scanned volumes
            self.EnforceConsistentVolumes();
        end
        
        function CreateCombiner(self)
        % ------------------------------------------------------------------
        % 
        % Create CombineEchoe instance
        % 
        % ------------------------------------------------------------------
            % nEchoes should be a vector of same length as runSeries, but can be provided as scalar for convenience
            if length(self.nEchoes) == 1
                self.nEchoes = repmat(self.nEchoes, size(self.runSeries));
            end

            % create combiner object
            % this call assumes that 30 first pulses of each run will be used to calculate the combining weights
            self.combiner = CombineEcho('filenamesDicom',   self.filenamesDicom,...
                                        'nEchoes',          self.nEchoes,...
                                        'outputDir',        self.outputDir,...
                                        'workingDir',       self.workingDir ...
                                       );
        end

        function RunCombining(self)
        % ------------------------------------------------------------------
        % 
        % Run all steps of the combiner-object in one go
        % 
        % -------------------------------------------------------------
            % run all combining steps
            self.combiner.DoMagic();
        end

        function files=ListAllFiles(self)
        % ------------------------------------------------------------------
        % 
        % Return and display all DICOM files, ie the content of 'filenamesDicom'
        % 
        % ------------------------------------------------------------------
        % this function is mostly for debugging
            files = self.filenamesDicom();
            disp(files)
        end


    end

    % ------------------------------------------------------------------------------------------------------------
    % ------------------------------------------------------------------------------------------------------------
    % Protected Methods
    % ------------------------------------------------------------------------------------------------------------
    % ------------------------------------------------------------------------------------------------------------

    methods(Access=protected)

        function GetAllDicomNames(self)
        % ------------------------------------------------------------------
        % 
        % for each Run, load all DICOM filenames
        % 
        % ------------------------------------------------------------------

        nRuns = length(self.runSeries);
            % if nEchoes given as scalar, it means that all runs had same number of echoes
            if length(self.nEchoes) == 1
                self.nEchoes = repmat(self.nEchoes, size(self.runSeries));
            end

            % load list of files for each run and echo, one at a time
            for iRun = nRuns:-1:1
                currentNEchoes = self.nEchoes(iRun);
                for iEcho = currentNEchoes:-1:1
                    % each echo has its own runSeries number. 
                    currentSeriesNumber = self.runSeries(iRun)+(iEcho-1);
                    
                    allFiles = dir([self.dataDir '/*.IMA']);
                     % use first DICOM to extract string-before-echo-number
                    firstDicomInfo = dicominfo([self.dataDir '/' allFiles(1).name]);
                    expDate = firstDicomInfo.InstanceCreationDate;
                    expDate = [expDate(1:4) '.' expDate(5:6) '.' expDate(7:8)];
                    stringBeforeEchoNumber = allFiles(3).name(strfind(allFiles(3).name,expDate)-16:strfind(allFiles(3).name,expDate)-12); % e.g. 'SKYRA'

                    % based on that info, select all DICOMs 
                    filesTemp = dir([self.dataDir '/*' stringBeforeEchoNumber '.' sprintf('%.4d', currentSeriesNumber) '*.IMA']);
                    fileNames = char(zeros(length(filesTemp),length(filesTemp(1).name)+2));
                    for i=1:size(fileNames ,1)
                        fileNames (i,1:length(filesTemp(i).name)) = filesTemp(i).name;
                    end
                    a = repmat([self.dataDir, '/'], size(fileNames,1),1);
                    self.filenamesDicom{iRun,iEcho}  = cat(2, a , fileNames);

                end
            end
           
        end
     



        function EnforceConsistentVolumes(self)
        % ------------------------------------------------------------------
        % 
        % Enforce same number of volumes for each echo
        % 
        % ------------------------------------------------------------------
        % make sure that all echoes have the same amount of images (delete any
        % volumes names from the list where not all echoes are available).
        % Otherwise, combining the echoes won't work.
        % 
        % NOTE: if you manually stop the scanner, you can end up with different
        % amounts of volumes for the different echoes. This is why we need this.. 


            nRuns = length(self.runSeries);

            for iRun = nRuns:-1:1 % starting with largest index essentially pre-allocates memory :)
                for iEcho = self.nEchoes(iRun):-1:1
                   tmp = self.filenamesDicom{iRun,iEcho}; % get list of files (char-matrix)
                   for iLine = size(tmp,1):-1:1
                       if length(tmp(iLine,:)) > 0 
                           break;
                       end
                   end
                   nVolumes(iEcho) = iLine;
                end


                ind = find( nVolumes(:) > min(nVolumes) )';
                if ~isempty(ind)
                    fprintf('Unequal amounts of volumes found. Going to skip last %i DICOMs\n', length(ind));
                    for i = ind
                        % get  list of files
                        tmp = self.filenamesDicom{iRun,i};
                        nTooMany = nVolumes(i) - min(nVolumes);
                        self.filenamesDicom{iRun,i} = tmp(1:(end-nTooMany),:);
                    end
                end
            end
        end
    end

end

