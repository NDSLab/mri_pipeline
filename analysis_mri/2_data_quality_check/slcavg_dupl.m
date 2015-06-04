function [slice_averages, new_imgs_headers] = slcavg_dupl(imgs_headers, mask, noise, cfg)
fprintf('\n\t\tCalculating slice averages...');
%spm_progress_bar('Init', size(imgs_headers, 1),['Calc slice averages / data duplication, mode ' cfg.runmode] );
new_imgs_headers = imgs_headers;
for volume = 1:size(imgs_headers,1)
    image = spm_read_vols(imgs_headers{volume});
    % create mask based on how we want to do it (see cfg)
    if strcmp('intensity', cfg.mask_type) == 1% use mask as calculated before
        if strcmp('yes', cfg.maskint.fix) == 1
            mask = mask;
        elseif strcmp('no', cfg.maskint.fix) == 1 % recualculate the mask
            vol_mean = mean (image(:));
            mask = zeros(size(image));
            if strcmp('inside_brain', cfg.correction_mode) == 1
                mask (find (image > cfg.maskint.int * mean_intensity)) = 1;
            elseif strcmp('outside_brain', cfg.maskint.mode) == 1
                mask (find (image <= cfg.maskint.int * mean_intensity)) = 1;
            else
                fprintf('\nproblem in check_spike subfunction slcavg_dupl: invalid correction mode!\n')
            end
        else
            fprintf('\nproblem in check_spike subfunction slcavg_dupl: invalid intensity-mask mode!\n')
        end
    elseif strcmp('noise', cfg.mask_type) == 1 % recalculate mask from noise
        mask = zeros(size(image));
        mask (find (image <= noise * cfg.masknoise)) = 1;
    elseif strcmp('noise_corner', cfg.mask_type) == 1
        mask = mask; % we have the mask and don;t need to recalculate!
    else
        fprintf('problem in spike_check subfunction slcavg_dupl: invalid mask type!\n\n')
    end
    
    %calculate slice averages (after application of mask)
    data = image .* mask;
    for slice = 1:size(data, 3)
        slice_data = data(:,:,slice);
        a = find (slice_data > 0);
        non_zero = slice_data (a);
        slice_averages (volume, slice) = mean (non_zero(:));
    end
    
    %duplicate volume IF we are in remove mode
    if (strcmp('remove', cfg.runmode) == 1) % recalculate mask from noise
        new_imgs_headers{volume}.descrip = ('un-spiked');
        if isempty(cfg.prefix_spike)
            movefile(imgs_headers{volume}.fname,cfg.spike_dir);
            new_imgs_headers{volume}.fname = imgs_headers{volume}.fname;
        else
            new_imgs_headers{volume}.fname = prepend(imgs_headers{volume}.fname, cfg.prefix_spike);
        end
        spm_write_vol(new_imgs_headers{volume}, image);
    end
    %spm_progress_bar('Set',volume);
end