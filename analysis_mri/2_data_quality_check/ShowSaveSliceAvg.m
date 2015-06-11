function linegraph = ShowSaveSliceAvg(SLICE_AVERAGES, VOLUME_INFO, config, iRun)
%
% This function shows slice averages in a histogram and save the graph.
%
% input
%       sliceAverages:
%       DATA: 
%       config:
%       iRun:
%       
% output
%       figure: the produced plot of normalized values of slices

    %%                      Save slice averages                          %%
    
    %Make nwe filename
    [~, ~, xt] = fileparts(deblank(VOLUME_INFO{1}.fname));
    fullname = fullfile(config.spikeDir,[sprintf('CheckSpike_SliceAvg_run%i',iRun) xt]);
    
    %Save data
    save(fullname,'sliceAverages');
    
    %%                      Show slice averages                          %%
    
    %Preallocate normalized slc_avg
    normSliceAverage = zeros(size(SLICE_AVERAGES));
    
    %Calculate how far a slice is in percentages from the mean.
    for i = 1:size(SLICE_AVERAGES, 2)
        normSliceAverage(:,i) = SLICE_AVERAGES(:,i) / mean(SLICE_AVERAGES(:,i));
    end
    
    % Make plot
    linegraph = figure(3); clf; plot(normSliceAverage); line((1:size(SLICE_AVERAGES, 1)), (1+config.spikeThreshold));
    v = axis; if v(4) < (1+config.spikeThreshold*1.5); v(4) = (1+config.spikeThreshold*1.5); end; axis(v);

end
