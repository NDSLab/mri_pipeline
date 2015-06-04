# Combining multi-echo images
===============================
## General Information
-------------------------------

Most data acquired at the Donders is multi-echo data. Per scan pulse, multiple volumes are acquired (usually four or five). This means that data is acquired at different points along the T2 decay curve. Different tissues have different T2 decay rates, so in one echo, signal intensity could be still high in some tissues, while it has already dropped in others. Data from the different echoes has to be combined to one dataset.

The following reference contains more information about the math behind the combine script:

Poser, B. A, Versluis, M. J., Hoogduin, J. M., & Norris, D. G. (2006). BOLD contrast sensitivity enhancement and artifact reduction with multiecho EPI: parallel-acquired inhomogeneity-desensitized fMRI. Magnetic Resonance in Medicine, 55(6), 1227–35. doi:10.1002/mrm.20900

