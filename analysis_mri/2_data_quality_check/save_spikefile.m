function save_spikefile(affected_vol_slc, affected_vol, imgs_headers,cfg,iRun)
%
% Creates filenames and saves affected volumes & slices.
%
    
    %Create new filename
    [~,~,xt] = fileparts(deblank(imgs_headers{1}.fname));
    fullname_vol = fullfile(cfg.spike_dir,[sprintf('CheckSpike_AffectedVols_run%i',iRun),xt]);
    fullname_vol_slc = fullfile(cfg.spike_dir,[sprintf('CheckSpike_AffectedVolsSlices_run%i',iRun) xt]);

    %Save affected volumes & slices
    save(fullname_vol,'affected_vol');
    save(fullname_vol_slc,'affected_vol_slc');
end
