function filesPrefixed = AddPrefix(filenames, prefix)
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