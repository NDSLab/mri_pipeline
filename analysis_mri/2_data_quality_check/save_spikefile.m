function save_spikefile(affected_vol_slc, affected_vol, imgs_headers,cfg,iRun)

[pth,nm,xt] = fileparts(deblank(imgs_headers{1}.fname));
fullname = fullfile(cfg.spike_dir,[sprintf('CheckSpike_AffectedVols_run%i',iRun),xt]);
save(fullname,'affected_vol');
fullname = fullfile(cfg.spike_dir,[sprintf('CheckSpike_AffectedVolsSlices_run%i',iRun) xt]);
save(fullname,'affected_vol_slc');