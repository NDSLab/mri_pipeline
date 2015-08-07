function justFilename = stripPath(fullPathFilename)
    [~, name, ext] = fileparts(fullPathFilename);
    justFilename = [name ext];
end