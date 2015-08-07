# Extracting beta values 

## MarsBaR

In matlab add the path to MarsBaR by typing:
```matlab
addpath('/home/common/matlab/spm12/toolbox/marsbar/')
```

When SPM is open, type marsbar in the command line to open MarsBaR.
You can define a ROI from your results by clicking: 
-ROI definition – Get SPM clusters.
In the toolbar of the results screen:
-click Write ROIs and choose write one cluster or all clusters. 

To extract beta values from the ROI you just created:
-click Design – Set design from file, and select the SPM.mat file of the contrast of interest.
-click Data – Extract ROI data (default), and select the ROI you created previously.

You can plot the values by selecting:
-Data – Plot data (simple). 

To save the beta values in a file, choose:
-Export data in the Data menu.
-choose Summary time course, and export to an Excel file. 
The values will be stored in a .csv file, but this is better than saving it as a text file and then choose .csv. 
