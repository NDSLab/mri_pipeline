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
    %   combiner = CombineEcho('runSeries',[7 11 15],'nEchoes',[4 4 4],'structuralSeries',19,'scannerName','Skyra');
    %   combiner.Run(); % runs all steps
    % 
    
    properties
        % Array of cell arrays; each cell array contains filenames of original DICOMS of ONE run
        % this should have all files, including the prescans -- see also property 'filenamesDicomPrescans'
        % Note: filenames MUST include full path info, that is also the '/home/username/projects/subject1/..' for each file
        filenamesDicom;

        % Integer - Number of runs
        nRuns;
        
        % array of integers - Number of Echoes - should be array of length = nRuns,e.g. [4 4 4]
        nEchoes;
        
        % Where should the combined files be saved in?
        outputDir; 
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% BELOW: These properties should only be set manually if going against our group's default
        
        %Number of Volumes used for calculating weights
        nWeightVolumes=30;

        % Array of cell arrays; each cell array contains filenames of original DICOMS of one run 
        % this should have only the scans which will be used for the weight calculation. 
        % Note: if not set manually, these will be picked as the first 'nWeightVolumes' from 'filenamesDicom' - this should be the default
        filenamesDicomPrescansOnly;

        % This script uses a working directory. This is assumed to be '/data', but can be manually overriden
        workingDir = '/data';

        % per default, only final output will be copied to the 'outputDir'
        keepIntermediaryFiles = false;
    end

    
    methods
        
        function self=CombineEcho(varargin)
        % ------------------------------------------------------------------
        % 
        % Construction - CombineEcho
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
            
            % by now, structuralSeries, runSeries, nEchoes, and scannerName 
            % should be set - verify that, if not report all errors at once.
            msg = '';
            someError = false; 
            if isempty(self.filenamesDicom)
                someError = true;
                msg = [msg 'filenamesDicom needs to be set when creating a CombineEcho instance\n'];
            end
            if isempty(self.scannerName)
                someError = true;
                msg = [msg 'scannerName needs to be set when creating a CombineEcho instance\n'];
            end
            if isempty(self.nEchoes)
                someError = true;
                msg = [msg 'nEchoes needs to be set when creating a CombineEcho instance\n'];  
            end
            if someError 
                error('CombineEcho:Constructor',msg);
                %disp(msg)
            end

            % apply defaults based on properties which may be set via constructor, so set them only if not yet set
            if isempty(self.prepscans)
                self.prepscans=repmat(30,length(self.runSeries),1); 
            end
            if isempty(self.prescanSeries)
                self.prescanSeries=self.runSeries;
            end
        end

        function self=Run(self)
        % ------------------------------------------------------------------
        % 
        % run all combining sub-parts in one go
        % 
        % ------------------------------------------------------------------
            self.ConvertDicoms();
            self.Realign();
            self.Reslice();
            self.calculateWeights();
            self.applyWeights();
        end

        function self=ConvertDicoms(self)
        % ------------------------------------------------------------------
        % 
        % converts DICOM images to nifti format
        % 
        % ------------------------------------------------------------------
            %some code
        end

        function self=Realign(self)
        % ------------------------------------------------------------------
        % 
        % realigns all images, per runs (double pass) and then across runs
        % 
        % ------------------------------------------------------------------
            %some code
        end

        function self=Reslice(self)
        % ------------------------------------------------------------------
        % 
        % reslices images
        % 
        % ------------------------------------------------------------------
            %some code
        end

        function self=CalculateWeights(self)
        % ------------------------------------------------------------------
        % 
        % calculates weights
        % 
        % ------------------------------------------------------------------
            %some code
        end

        function self=applyWeights(self)
        % ------------------------------------------------------------------
        % 
        % applies weights to all images
        % 
        % ------------------------------------------------------------------
            %some code
        end
end

