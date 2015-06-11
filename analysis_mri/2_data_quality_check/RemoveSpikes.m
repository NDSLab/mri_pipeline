function RemoveSpikes(AFFECTED_VOLUME_SLICE, DATA, NEW_IMAGE_INFO)
%
% This function removes affected slices by means of the adjecent
% slices. The new volumes are saved under the new imgs headers.

    %%              Detect and replace spikes
    
    %Per volume
    for volume = 2:size(AFFECTED_VOLUME_SLICE, 1)-1
        
        % Per slice
        for slice = 1:size(AFFECTED_VOLUME_SLICE, 2)
            
            %If the slice is affected, replace it
            if ( AFFECTED_VOLUME_SLICE(volume, slice) == 1 )
                
                fprintf('\ncorrecting vol %2d slice %2d.\n', volume, slice);
                
                % load the previous and following volume....
                previousVol = DATA(:,:,:,volume-1);
                followingVol = DATA(:,:,:,volume+1);
                               
                % do the deed and replace affected slice by the average of adjecent
                currentVol = (previousVol(:,:, slice) + followingVol(:,:, slice)) ./ 2;
                
                %save the corrected volume
                spm_write_plane(NEW_IMAGE_INFO{volume}, currentVol, slice);
                
                %Tell us that a spike is replaced
                disp (strcat ('removed spike in file', ' ' , NEW_IMAGE_INFO{volume}.fname));
            end
        end
    end
end