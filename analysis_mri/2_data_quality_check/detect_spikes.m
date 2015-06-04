function [affected_vol_slc, affected_vol] = detect_spikes(slice_averages, cfg)
%spm_progress_bar('Init', (size(slice_averages, 1) -1),'Spike detection');
affected_vol_slc  = zeros (size(slice_averages, 1), size(slice_averages, 2));
affected_vol = zeros (size(slice_averages, 1),1);
mean_slice_averages = mean(slice_averages, 1);
for volume = 2:size(slice_averages, 1)-1
    for slice = 1:size(slice_averages, 2)
        if strcmp('previous_vol', cfg.base_cor_on) == 1
            if (  (slice_averages (volume, slice) - slice_averages(volume-1, slice) )  > cfg.spike_threshold * slice_averages(volume-1, slice) )
                affected_vol_slc(volume, slice) = 1;
                affected_vol(volume) = 1;
            end
        elseif strcmp('timecourse_avg', cfg.base_cor_on) == 1
            if (  (slice_averages (volume, slice) - mean_slice_averages(1, slice) )  > cfg.spike_threshold * slice_averages(volume-1, slice) )
                affected_vol_slc(volume, slice) = 1;
                affected_vol(volume) = 1;
            end
        else
            fprintf('\nproblem in spike_check subfunction detect_spikes: invalid correction mode!\n')
        end
    end %slice
    %spm_progress_bar('Set',volume-1);
end %volume