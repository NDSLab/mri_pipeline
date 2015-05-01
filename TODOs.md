TODOs
===========


* add spike detection to combine script

* refactor helper function (e.g. Cell-to-Matrix-for-files function) into dedicated module, for easy reuse

* In CombineEcho.Realign():  add check for files(i,:,j) not being empty -- spm_get_space will through an error about hdr if it is..
  this can esp. happen if one run has fewer/more echoes than the other runs (e.g. because resting state) 



[ optional TODOs]
---------------

* add smoothing of weights

* check which exact version of SPM12 to use (SPM12? SPM12b? others?)