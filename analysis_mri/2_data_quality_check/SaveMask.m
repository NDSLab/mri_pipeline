function save_mask(mask,imgs_headers,cfg,iRun)
%    
% This funtion saves the mask as spm volume made by getmask.m
% Mask is saved in spike directory
%
% Input
% mask: from getmask.m
% imgs_headers: volume information from spm_vol
% cfg: information (INFO)
% iRun: spikes from which run.
    
    %Create volume information from original volumes
    header = imgs_headers{1};
    [~,~,ext] = fileparts(deblank(header.fname));
    header.fname = fullfile(cfg.spike_dir,[sprintf('CheckSpike_Mask_run%i',iRun) ext]);
    header.descrip = ('CheckSpike_Mask');
    
    %Save mask volume information
    spm_write_vol(header, mask);
    
end