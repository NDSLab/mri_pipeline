function move_first_nLines_to_otherFile(filename_original, filename_first, nLinesToMove)
% this function opens a file (e.g. a text file) and extracts the first
% nLinesToMove into another file. The remaining lines are left inside the
% file 
%%% Example: 
% moves first 10 lines from source.txt into headers.txt
% move_first_nLines_to_otherFile('source.txt','headers.txt',10);
%

% ensure that new file doesn't exist yet:
if exist(filename_first,'file')
    error('Error: output file %s already exists! Aborting to move %i lines from file %s into it.',...
        filename_first, nLinesToMove, filename_original)
end
% open files
f_orig  = fopen(filename_original,'r');
f_first = fopen(filename_first,'w');

% get nLinesToMove and write the to f_first file
for i=1:nLinesToMove
    textline = fgetl(f_orig);
    fprintf(f_first, '%s\n', textline);
end

% close file with extracted lines
fclose(f_first);

% now read the rest of the file
buffer = fread(f_orig);
% close file (reading only permission!)
fclose(f_orig);
% reopen file with writing permission -- deletes automatically previous
% content 
f_orig = fopen(filename_original,'w');
% write buffer to file and close
fwrite(f_orig, buffer);
fclose(f_orig);

end