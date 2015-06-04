#Guidelines for 2nd level analyses
===============
The second level analysis is an analysis on the group level. This very much depends on your dataset. 
In the folder you use for the second level analysis, make a folder for all the contrasts previously defined. Add a Factorial design specifications for every contrast you want to look at.  

For Design, the options are One-sample t-test, Two-sample t-test, Paired t-test, Multiple regression, One-way ANOVA, One-way ANOVA – within subject, Full factorial, and Flexible factorial. Which option to choose depends on the structure of your data. A two-sample t-test is used when two groups are compared (eg. Oxytocin vs Placebo), and a paired t-test is used when two scan sessions of the same participant are compared. Multiple regression allows you to add a covariate. 

See the image below for the second level parameters:
![Second level parameters] (mri_pipeline/wiki/pages/uploads/images/second level parameters.jpg)

After you have run this, you can click Results. Select an SPM.mat file for the contrast you are interested in, and click Define new contrast. Provide a name for the contrast, and enter the contrast weights vector (these depend on the contrast you’re viewing), and click Done. 

See the image below for the results parameters:
![Results parameters] (mri_pipeline/wiki/pages/uploads/images/results parameters.jpg)

To overlay the activity maps on a brain picture, click overlays -> sections in the lower left window.