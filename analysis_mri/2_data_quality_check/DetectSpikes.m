function [affectedVolSlice, affectedVol] = DetectSpikes(SLICE_AVERAGE, config)
    %
    % This function detects spikes in volumes and slices. It has two modes
    % of operation: 
    %
    % 1. previous volume
    %   Select a slice if its value is larger than: threshold * mean(previous volume)    
    %
    % 2. timevourse average
    %   Select a slice if its value is larger than: threshold * mean(slice over all volumes)     
    %
    % Input
    %       SLICE_AVERAGE = averages from slcavg_dupl.m
    %       config = configuration information (INFO)
    %
    % Output
    %       affectedVolSlice = matrix with size (volumes, slices), 1 is affected slice
    %       affectedVol = vector with length of all volumes. 1 is affected volume.    


    %Give message
    disp('Detecting spikes')
   
    %Preallocate affected volume information
    affectedVolSlice  = zeros(size(SLICE_AVERAGE, 1), size(SLICE_AVERAGE, 2));
    affectedVol = zeros (size(SLICE_AVERAGE, 1),1);
    meanSliceAverages = mean(SLICE_AVERAGE, 1);

    %%                    Detect spikes                                  %%
    
    %Per volume
    for volume = 2:size(SLICE_AVERAGE, 1)-1
        
        %Count how many spikes per volume, 1+ is problematic!
        count = 0;
        
        %Per slice
        for slice = 1:size(SLICE_AVERAGE, 2)
            
            % Select slices based on previous volume
            if strcmp('previousVolume', config.selectionMethod) == 1
                if ((SLICE_AVERAGE(volume, slice) - SLICE_AVERAGE(volume-1,slice))  > config.spikeThreshold * SLICE_AVERAGE(volume-1, slice) )
                    affectedVolSlice(volume, slice) = 1;
                    affectedVol(volume) = 1;
                    count = count +1;
                end
             
            % Select affected slices 
            elseif strcmp('timecourseAverage', config.selectionMethod) == 1
                
                %Select affected slices:
                if ((SLICE_AVERAGE(volume, slice) - meanSliceAverages(1, slice) )  > config.spikeThreshold * SLICE_AVERAGE(volume-1, slice) )
                    affectedVolSlice(volume, slice) = 1;
                    affectedVol(volume) = 1;
                    count = count +1;
                    
                end
            else
                fprintf('\nproblem in spike_check subfunction DetectSpikes: invalid correction mode!\n')
            end
        end
        
        %Give alert when there are more than 2 spikes per volume
        if count > 1
            fprintf('\n\n\t\tPROBLEM: more than one spike occured in one volume\n\n')
        end
    end 
end

    
    
    
    
    
    