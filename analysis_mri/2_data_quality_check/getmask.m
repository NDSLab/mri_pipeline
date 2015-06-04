function [mask, noise]  = getmask(imgs_headers, cfg)
%    
% This function is able to create three mask types. Typically, Noise_corner
% is used
% 1. Intensity: simple intensity mask (inside/outside brain)
% 2. Noise: creates mask based on typical noise*cfg.masknoise
% 3. Noise_corner: take what's definetly noise: 8x8 pixels in each corner of each slice
%
% Recommended by Paul Gaalman 2015-5-1: noise_corner.
%    
% Input: 
% imgs_headers = volume information from smp_vol
% cfg = spike detection information (INFO)
%
% Output:
% mask = appropriate mask
% noise = 

    %Give start message
    disp('Get Mask.');
    
    
    %% Preallocate a mask volume
    
    % Get data from first 5 volumes   
    for i = 1:5
        headers(i) = imgs_headers{i};
    end
    image_data = spm_read_vols(headers);
    
    % Get average volume information
    average_volume = mean(image_data, 4);
    average_volume = reshape(average_volume, size(average_volume, 1), size(average_volume, 2), size(average_volume, 3));
    mean_intensity = mean(average_volume(:));
    mask = zeros(size(average_volume));

    %% Create one of three types of mask volume
    
    if strcmp('intensity', cfg.mask_type) == 1
        
        % Creates mask based on typical noise*cfg.masknoise
        
        if strcmp('inside_brain', cfg.correction_mode) == 1
            mask(average_volume > cfg.maskint.int * mean_intensity) = 1;
        elseif strcmp('outside_brain', cfg.maskint.mode) == 1
            mask(average_volume <= cfg.maskint.int * mean_intensity) = 1;
        else
            fprintf('\nproblem in check_spike subfunction getmask: invalid correction mode!\n')
        end
        noise = 'dummy';
        
    elseif strcmp('noise', cfg.mask_type) == 1
        
        % Creates mask based on typical noise*cfg.masknoise
        % Logic in lay peoples language: a wide circle around the brain must surely be noise.
        
        tmp = average_volume(2:9, 2:9, :); noise(1) = mean(tmp(:));
        tmp = average_volume(2:9, (size(average_volume, 2)-1):-1:(size(average_volume, 2)-8), :) ; noise(2) = mean(tmp(:));
        tmp = average_volume((size(average_volume, 1)-1):-1:(size(average_volume, 1)-8), 2:9, :) ; noise(3) = mean(tmp(:));
        tmp = average_volume((size(average_volume, 1)-1):-1:(size(average_volume, 1)-8), (size(average_volume, 2)-1):-1:(size(average_volume, 2)-8), :); noise(4) = mean(tmp(:));
        noise = mean(noise);
        mask(average_volume <= noise * cfg.masknoise) = 1;
        
    elseif strcmp('noise_corner', cfg.mask_type) == 1
        
        % Take what's definetly noise: 8x8 pixels in each corner of each slice
        
        mask(2:9, 2:9, :) = 1;                                              
        mask(2:9, (size(mask, 2)-1):-1:(size(mask, 2)-8), :) =1;            
        mask((size(mask, 1)-1):-1:(size(mask, 1)-8), 2:9, :)  =1;           
        mask((size(mask, 1)-1):-1:(size(mask, 1)-8), (size(mask, 2)-1):-1:(size(mask, 2)-8), :) =1;
        noise = 'dummy';
        
    else
        %%                   Error message                               %%
        
        fprintf('\nproblem in check_spike subfunction getmask: invalid mask_type!\n')
    end
end