function [affected_vol_slc, affected_vol] = detect_spikes(slice_averages, cfg)
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
    % slice averages = averages from slcavg_dupl.m
    % cfg = configuration information (INFO)
    %
    % Output
    % affected_vol_slc = matrix with size (volumes, slices), 1 is affected
    % slice
    % affected_vol = vector with length of all volumes. 1 is affected
    % volume.    


    %Give message
    disp('Detecting spikes')
   
    %Preallocate affected volume information
    affected_vol_slc  = zeros (size(slice_averages, 1), size(slice_averages, 2));
    affected_vol = zeros (size(slice_averages, 1),1);
    mean_slice_averages = mean(slice_averages, 1);

    %%                    Detect spikes                                  %%
    
    %Per volume
    for volume = 2:size(slice_averages, 1)-1
        
        %Count how many spikes per volume, 1+ is problematic!
        count = 0;
        
        %Per slice
        for slice = 1:size(slice_averages, 2)
            
            % Select slices based on previous volume
            if strcmp('previous_vol', cfg.base_cor_on) == 1
                if ((slice_averages(volume, slice) - slice_averages(volume-1,slice))  > cfg.spike_threshold * slice_averages(volume-1, slice) )
                    affected_vol_slc(volume, slice) = 1;
                    affected_vol(volume) = 1;
                    count = count +1;
                end
             
            % Select affected slices 
            elseif strcmp('timecourse_avg', cfg.base_cor_on) == 1
                
                %Select affected slices:
                if ((slice_averages(volume, slice) - mean_slice_averages(1, slice) )  > cfg.spike_threshold * slice_averages(volume-1, slice) )
                    affected_vol_slc(volume, slice) = 1;
                    affected_vol(volume) = 1;
                    count = count +1;
                    
                end
            else
                fprintf('\nproblem in spike_check subfunction detect_spikes: invalid correction mode!\n')
            end
        end
        
        %Give alert when there are more than 2 spikes per volume
        if count > 1
            fprintf('\n\n\t\tPROBLEM: more than one spike occured in one volume\n\n')
        end
    end 
end

    
    
    
    
    
    