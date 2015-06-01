function h = show_save_slice_avg(slice_averages, imgs_headers, cfg, iRun)
%
% Show slice averages and save the graphs
%
%
    %%                      Save slice averages                          %%
    
    %Make nwe filename
    [~, ~, xt] = fileparts(deblank(imgs_headers{1}.fname));
    fullname = fullfile(cfg.spike_dir,[sprintf('CheckSpike_SliceAvg_run%i',iRun) xt]);
    
    %Save data
    save(fullname,'slice_averages');
    
    %%                      Show slice averages                          %%
    
    %Preallocate normalized slc_avg
    norm_slc_avg = zeros(size(slice_averages));
    
    %Calculate how far a slice is in percentages from the mean.
    for i = 1:size(slice_averages, 2)
        norm_slc_avg(:,i) = slice_averages(:,i) / mean(slice_averages(:,i));
    end
    
    % Make plot
    h = figure(3); clf; plot(norm_slc_avg); line((1:size(slice_averages, 1)), (1+cfg.spike_threshold));
    v = axis; if v(4) < (1+cfg.spike_threshold*1.5); v(4) = (1+cfg.spike_threshold*1.5); end; axis(v);

end
