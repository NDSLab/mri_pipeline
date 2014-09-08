function [mask, noise]  = getmask(imgs_headers, cfg)

for i = 1:5
    headers(i) = imgs_headers{i};
end
image_data = spm_read_vols(headers);
average_volume = mean (image_data, 4);
average_volume = reshape(average_volume, size(average_volume, 1), size(average_volume, 2), size(average_volume, 3));
mean_intensity = mean(average_volume(:));
mask = zeros(size(average_volume));

if strcmp('intensity', cfg.mask_type) == 1
    if strcmp('inside_brain', cfg.correction_mode) == 1
        mask (find (average_volume > cfg.maskint.int * mean_intensity)) = 1;
    elseif strcmp('outside_brain', cfg.maskint.mode) == 1
        mask (find (average_volume <= cfg.maskint.int * mean_intensity)) = 1;
    else
        fprintf('\nproblem in check_spike subfunction getmask: invalid correction mode!\n')
    end
    noise = 'dummy';
elseif strcmp('noise', cfg.mask_type) == 1
    % take what's definetly noise: 8x8 pixels in each corner of each slice
    tmp = average_volume(2:9, 2:9, :); noise(1) = mean(tmp(:));
    tmp = average_volume(2:9, (size(average_volume, 2)-1):-1:(size(average_volume, 2)-8), :) ; noise(2) = mean(tmp(:));
    tmp = average_volume((size(average_volume, 1)-1):-1:(size(average_volume, 1)-8), 2:9, :) ; noise(3) = mean(tmp(:));
    tmp = average_volume((size(average_volume, 1)-1):-1:(size(average_volume, 1)-8), (size(average_volume, 2)-1):-1:(size(average_volume, 2)-8), :); noise(4) = mean(tmp(:));
    noise = mean(noise);
    mask (find (average_volume <= noise * cfg.masknoise)) = 1;
elseif strcmp('noise_corner', cfg.mask_type) == 1
    mask(2:9, 2:9, :) = 1;
    mask(2:9, (size(mask, 2)-1):-1:(size(mask, 2)-8), :) =1;
    mask((size(mask, 1)-1):-1:(size(mask, 1)-8), 2:9, :)  =1;
    mask((size(mask, 1)-1):-1:(size(mask, 1)-8), (size(mask, 2)-1):-1:(size(mask, 2)-8), :) =1;
    noise = 'dummy';
else
    fprintf('\nproblem in check_spike subfunction getmask: invalid mask_type!\n')
end