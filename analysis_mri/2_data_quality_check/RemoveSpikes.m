function remove_spikes(affected_vol_slc, new_imgs_headers)
%
% This function removes affected slices by means of the adjecent
% slices. The new volumes are saved under the new imgs headers.

    %%              Detect and replace spikes
    
    %Per volume
    for volume = 2:size(affected_vol_slc, 1)-1
        
        % Per slice
        for slice = 1:size(affected_vol_slc, 2)
            
            %If the slice is affected, replace it
            if ( affected_vol_slc(volume, slice) == 1 )
                
                fprintf('\ncorrecting vol %2d slice %2d.\n', volume, slice);
                
                % load the previous and following volume....
                previous_vol  = spm_read_vols(new_imgs_headers{volume-1});
                following_vol = spm_read_vols(new_imgs_headers{volume+1});
                
                % do the deed and replace affected slice by the average of adjecent
                current_vol(:,:, slice) = (previous_vol(:,:, slice) + following_vol(:,:, slice)) ./ 2;
                
                %save the corrected volume
                spm_write_plane(new_imgs_headers{volume}, current_vol(:,:,slice), slice);
                
                %Tell us that a spike is replaced
                disp (strcat ('removed spike in file', ' ' , new_imgs_headers{volume}.fname));
            end
        end
    end
end