function SaveSpikefile(AFFECTED_VOLUME_SLICE, AFFECTED_VOLUME, VOLUME_INFO, config,iRun)
%
% Creates filenames and saves affected volumes & slices.
%
    
    %Create new filename
    [~,~,xt] = fileparts(deblank(VOLUME_INFO{1}.fname));
    fullname_vol = fullfile(config.spike_dir,[sprintf('CheckSpike_AffectedVols_run%i',iRun),xt]);
    fullname_vol_slc = fullfile(config.spike_dir,[sprintf('CheckSpike_AffectedVolsSlices_run%i',iRun) xt]);

    %Save affected volumes & slices
    save(fullname_vol,'AFFECTED_VOLUME');
    save(fullname_vol_slc,'AFFECTED_VOLUME_SLICE');
end
