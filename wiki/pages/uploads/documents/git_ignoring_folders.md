How to make git ignore files and folders (e.g. with your data)
=================================================

Typically, the `.gitignore` file is used to specify which files git should ignore and never track them. However, this file itself can (and most likely should) be tracked itself. Per default, this file contains some sensible things, based on a github help page. 

In case you add your own data, your folder names will be different (e.g. because of project number) from everyone else, so you should *not* add those to the `.gitignore` file (which could be uploaded in the next push). Instead, you should add those to the file `exclude` in the folder `.git/info`. 

For example, you can add `3014*/` to exclude all folders that start with '3014'.