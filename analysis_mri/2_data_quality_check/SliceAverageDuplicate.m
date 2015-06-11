function [sliceAverages, newImgsInfo] = SliceAverageDuplicate(DATA, MASK, config)
%
% This function calculates slice averages which spike detection is based
% on. Only calculates average of the mask area. If remove mode is on, this
% function duplicates volumes to save original volumes with spikes.
%
% Input
%       DATA = volume information
%       MASK from getmask.m
%       config = configuration information (INFO)
%
% Output
%       slice_averages = matrix with slice averages
%       new_imgs_headers = copies for unspiked volumes


    %%                   Start Calculation                               %%      
        
    fprintf('\nCalculating slice averages...\n');

    %Copy volume information
    newImgsInfo = DATA;
    
    %Preallocate
    sliceAverages = zeros(size(DATA,1), size(MASK,3));
    
    %Calculate per volume
    for volume = 1:size(DATA,1)
        
        %Read volume
        image = spm_read_vols(DATA{volume});
        
        % Recalculate mask for every volume if necessary (config.maskIntensity.fix) 
        if strcmp('intensity', config.maskType) == 1
            
            % recualculate the mask for every volume if necessary
            if strcmp('no', config.maskIntensity.fix) == 1 
                MASK = zeros(size(image));
                if strcmp('inside_brain', config.maskIntensity.mode) == 1
                    MASK(image > config.maskIntensity.int * mean_intensity) = 1;
                elseif strcmp('outside_brain', config.maskIntensity.mode) == 1
                    MASK(image <= config.maskIntensity.int * mean_intensity) = 1;
                else
                    fprintf('\nproblem in checkSpike subfunction slcavg_dupl: invalid correction mode!\n')
                end
            end
        end

        %calculate slice averages (after application of mask)
        maskedData = image .* MASK;
        for slice = 1:size(maskedData, 3)
            sliceData = maskedData(:,:,slice);
            nonZero = sliceData(sliceData>0);
            sliceAverages(volume, slice) = mean(nonZero(:));
        end

        %duplicate volume IF we are in remove mode
        if (strcmp('remove', config.mode) == 1) % recalculate mask from noise
            newImgsInfo{volume}.descrip = ('un-spiked');
            
            %Save with a new prefix if we asked for that.
            if isempty(config.prefixSpike)
                movefile(DATA{volume}.fname,config.spikeDir);
                newImgsInfo{volume}.fname = DATA{volume}.fname;
            else
                [path, name, ext] = fileparts(deblank(DATA{volume}.fname));
                newImgsInfo{volume}.fname = [path, strcat(config.prefixSpike, name), ext];
            end
            
            %Write new volumes
            spm_write_vol(newImgsInfo{volume}, image);
        end
    end
    
    fprintf('Done.\n');
    
end