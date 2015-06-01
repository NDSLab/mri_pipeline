function [slice_averages, new_imgs_headers] = slcavg_dupl(imgs_headers, mask, cfg)
%
% This function calculates slice averages which spike detection is based
% on. Only calculates average of the mask area. If remove mode is on, this
% function duplicates volumes to save original volumes with spikes.
%
% Input
% imgs_headers = volume information
% mask from getmask.m
% cfg = configuration information (INFO)
%
% Output
% slice_averages = matrix with slice averages
% new_imgs_headers = copies for unspiked volumes


    %%                   Start Calculation                               %%      
        
    fprintf('\nCalculating slice averages...\n');

    %Copy volume information
    new_imgs_headers = imgs_headers;
    
    %Preallocate
    slice_averages = zeros(size(imgs_headers,1), size(mask,3));
    
    %Calculate per volume
    for volume = 1:size(imgs_headers,1)
        
        %Read volume
        image = spm_read_vols(imgs_headers{volume});
        
        % Recalculate mask for every volume if necessary (cfg.maskint.fix
        if strcmp('intensity', cfg.mask_type) == 1
            
            % recualculate the mask for every volume if necessary
            if strcmp('no', cfg.maskint.fix) == 1 
                mask = zeros(size(image));
                if strcmp('inside_brain', cfg.correction_mode) == 1
                    mask(image > cfg.maskint.int * mean_intensity) = 1;
                elseif strcmp('outside_brain', cfg.maskint.mode) == 1
                    mask(image <= cfg.maskint.int * mean_intensity) = 1;
                else
                    fprintf('\nproblem in check_spike subfunction slcavg_dupl: invalid correction mode!\n')
                end
            end
        end

        %calculate slice averages (after application of mask)
        data = image .* mask;
        for slice = 1:size(data, 3)
            slice_data = data(:,:,slice);
            non_zero = slice_data(slice_data>0);
            slice_averages(volume, slice) = mean(non_zero(:));
        end

        %duplicate volume IF we are in remove mode
        if (strcmp('remove', cfg.mode) == 1) % recalculate mask from noise
            new_imgs_headers{volume}.descrip = ('un-spiked');
            
            %Save with a new prefix if we asked for that.
            if isempty(cfg.prefix_spike)
                movefile(imgs_headers{volume}.fname,cfg.spike_dir);
                new_imgs_headers{volume}.fname = imgs_headers{volume}.fname;
            else
                [path, name, xt] = fileparts(deblank(imgs_headers{volume}.fname));
                new_imgs_headers{volume}.fname = [path, strcat(cfg.prefix_spike, name), xt];
            end
            
            %Write new volumes
            spm_write_vol(new_imgs_headers{volume}, image);
        end
    end
    
    fprintf('Done.\n');
    
end