function remove_spikes(affected_vol_slc, new_imgs_headers)
%spm_progress_bar('Init', (size(affected_vol_slc, 1) -1),'Spike removal');
for volume = 2:size(affected_vol_slc, 1)-1
    for slice = 1:size(affected_vol_slc, 2)
        if ( affected_vol_slc(volume, slice) == 1 )
            fprintf('\n\t\tcorrecting vol %2d slice %2d', volume, slice);
            % load the previous and following volume....
            previous_vol  = spm_read_vols(new_imgs_headers{volume-1});
            following_vol = spm_read_vols(new_imgs_headers{volume+1});
            % do the deed and replace affected slice by the average of adjecent
            current_vol (:,:, slice) = ( previous_vol (:,:, slice) + following_vol (:,:, slice)  ) ./ 2;
            %save the corrected volume
            spm_write_plane(new_imgs_headers{volume},current_vol(:,:,slice), slice);
            %disp (strcat ('removed spike in file', ' ' , new_imgs_headers{volume}.fname));
        end
    end
    %spm_progress_bar('Set',volume-1);
end