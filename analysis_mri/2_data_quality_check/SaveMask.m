function SaveMask(MASK,VOLUME_INFO,config,iRun)
%    
% This funtion saves the mask as spm volume made by GetMask.m
% Mask is saved in quality check output directory
%
% Input
%       mask: from getmask.m
%       DATA: volume information from spm_vol
%       cfg: information (INFO)
%       iRun: spikes from which run.
%
% Output
%       Saves mask as nifti file. 
%
    
    %Create volume information from original volumes
    header = VOLUME_INFO{1};
    [~,~,ext] = fileparts(deblank(header.fname));
    header.fname = fullfile(config.spikeDir,[sprintf('CheckSpike_Mask_run%i',iRun) ext]);
    header.descrip = ('CheckSpike_Mask');
    
    %Save mask volume information
    spm_write_vol(header, MASK);
    
end