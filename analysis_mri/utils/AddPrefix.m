function filesPrefixed = AddPrefix(filenames, prefix)
% AddPrefix(filenames, prefix) takes list of files (fullpath) and adds a
% prefix to each file.
% 
% Input:
%   filenames           ... char-matrix or cell-array of char-matrices,
%                           where each line of the char-matrix is a
%                           full-path filename
%   prefix              ... string. desired prefix, e.g. 'c'
% 
% Output:
%   filesPrefixed       ... same as filenames, but with files prefixed with
%                           'prefix'
% 

if iscell(filenames)
    for i=numel(filenames):-1:1
        tmp = filenames{i};
        for iFiles=size(tmp,1):-1:1
            [pathstr, name, ext] = fileparts(tmp(iFiles,:));
            out(iFiles,:) = char([pathstr '/' prefix name ext]);
        end
        filesPrefixed{i} = out; clear out;
    end
    filesPrefixed=reshape(filesPrefixed,size(filenames));
else
    [pathstr, name, ext] = fileparts(filenames);
    filesPrefixed = char([pathstr '/' prefix name ext]);
end
end