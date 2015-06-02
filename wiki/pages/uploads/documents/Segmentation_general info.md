#Preprocessing
===============
##Segmentation
---------------

###General Information

During the segmentation step, your structural images are separated into grey matter, white matter, and CSF. Your images are compared to standard SPM tissue probability maps.

After segmentation, several new images have been created in the structural folder. The prefixes tell you which procedures the images have undergone. 

| Prefix | Image                            |
|--------|----------------------------------|
| m      | bias corrected image             |
| c1     | segmented gray matter            |
| c2     | segmented white matter           |
| c3     | sgmented CSF                     |
| wm     | normalized, bias corrected image |

