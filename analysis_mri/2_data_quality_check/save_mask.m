function save_mask(mask,imgs_headers,cfg,iRun)
header = imgs_headers{1};
[pth,nm,xt] = fileparts(deblank(header.fname));
header.fname = fullfile(cfg.spike_dir,[sprintf('CheckSpike_Mask_run%i',iRun) xt]);
header.descrip = ('CheckSpike_Mask');
spm_write_vol(header, mask);