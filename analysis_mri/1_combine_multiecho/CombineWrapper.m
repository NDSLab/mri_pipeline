classdef CombineWrapper < handle
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
        %Series of Structural files
        % The series number of your structural scans (see Print List). Look
        % for the series number of t1_mprage_sag (192 scans).
        structuralSeries; 

        %Series corresponding to first echo of each run
        % The series numbers of where each run starts. This should be
        % consistent with expArray
        runSeries;
        
        %Number of Echoes - should be array of length=nRuns,e.g. [4 4 4]
        nEchoes;
        
        % The following is used to identify all dicom files, coming from a
        % scanner.
        % Valid options: {'Skyra','Avanto','Trio'}
        % pick the one applying by setting the index
        scannerName;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% BELOW: Only needs editing if not following group-defaults
        
        %Number of Volumes used for calculating weights
        nWeightVolumes=30;

        %Number of prepscans for each run, files will be moved to prepscan folders
        % These scans will not be used in your analysis, but for combining
        % multi-echo data. The series numbers of where you started with 30 pulses
        % (the prescans). We decided that we need 30 pulses before every run.
        prepscans%=repmat(30,length(runSeries),1); % default will be set by constructor
        
        %Series corresponding to first echo of each prescan
        % The series numbers of where you started with 30 pulses (the prescans). We
        % decided that we need 30 pulses before every run, so prescanSeries should
        % contain the same numbers as runSeries.
        prescanSeries%=runSeries; % default will be set by constructor
                
    end

    properties(Access=private)
        % state variable
        state=1; % keeps track of progress of combining
    end
    
    methods
        
        function self=CombineWrapper(varargin)
        % ------------------------------------------------------------------
        % 
        % Construction - CombineEcho
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
            
            % by now, structuralSeries, runSeries, nEchoes, and scannerName 
            % should be set - verify that, if not report all errors at once.
            msg = '';
            someError = false; 
            if isempty(self.runSeries)
                someError = true;
                msg = [msg 'runSeries needs to be set when creating a CombineEcho instance\n'];
            end
            if isempty(self.scannerName)
                someError = true;
                msg = [msg 'scannerName needs to be set when creating a CombineEcho instance\n'];
            end
            if isempty(self.structuralSeries)
                someError = true;
                msg = [msg 'structuralSeries needs to be set when creating a CombineEcho instance\n'];
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

