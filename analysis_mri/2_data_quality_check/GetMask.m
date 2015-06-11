function [mask, noise]  = GetMask(DATA, config)
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
%       DATA = volume information per run
%       config = spike detection information
%
% Output:
%       mask = appropriate mask
%       noise = 

    %Give start message
    disp('Get Mask.');
    
    
    %% Preallocate a mask volume
    
    % Get data from first 5 volumes   
    imageData = DATA(:,:,:,1:5);
    

    % Get average volume information
    averageVolume = mean(imageData, 4);
    averageVolume = reshape(averageVolume, size(averageVolume, 1), size(averageVolume, 2), size(averageVolume, 3));
    meanIntensity = mean(averageVolume(:));
    mask = zeros(size(averageVolume));    

    %% Create one of three types of mask volume
    
    if strcmp('intensity', config.maskType) == 1
        
        % Creates mask based on typical noise*cfg.masknoise
        
        if strcmp('inside_brain', config.maskIntensity.mode) == 1
            mask(averageVolume > config.maskIntensity.int * meanIntensity) = 1;
        elseif strcmp('outside_brain', config.maskIntensity.mode) == 1
            mask(averageVolume <= config.maskIntensity.int * meanIntensity) = 1;
        else
            fprintf('\nproblem in check_spike subfunction getmask: invalid correction mode!\n')
        end
        noise = 'dummy';
        
    elseif strcmp('noise', config.maskType) == 1
        
        % Creates mask based on typical noise*cfg.masknoise
        % Logic in lay peoples language: a wide circle around the brain must surely be noise.
        
        tmp = averageVolume(2:9, 2:9, :); noise(1) = mean(tmp(:));
        tmp = averageVolume(2:9, (size(averageVolume, 2)-1):-1:(size(averageVolume, 2)-8), :) ; noise(2) = mean(tmp(:));
        tmp = averageVolume((size(averageVolume, 1)-1):-1:(size(averageVolume, 1)-8), 2:9, :) ; noise(3) = mean(tmp(:));
        tmp = averageVolume((size(averageVolume, 1)-1):-1:(size(averageVolume, 1)-8), (size(averageVolume, 2)-1):-1:(size(averageVolume, 2)-8), :); noise(4) = mean(tmp(:));
        noise = mean(noise);
        mask(averageVolume <= noise * config.masknoise) = 1;
        
    elseif strcmp('noise_corner', config.maskType) == 1
        
        % Take what's definetly noise: 8x8 pixels in each corner of each slice
        
        mask(2:9, 2:9, :) = 1;                                              
        mask(2:9, (size(mask, 2)-1):-1:(size(mask, 2)-8), :) =1;            
        mask((size(mask, 1)-1):-1:(size(mask, 1)-8), 2:9, :)  =1;           
        mask((size(mask, 1)-1):-1:(size(mask, 1)-8), (size(mask, 2)-1):-1:(size(mask, 2)-8), :) =1;
        noise = 'dummy';
        
    else
        %%                   Error message                               %%
        
        fprintf('\nproblem in checkSpike structure maskType: invalid mask_type!\n')
    end
end