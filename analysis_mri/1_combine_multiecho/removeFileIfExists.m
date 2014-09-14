function removeFileIfExists(file_name)
if exist(file_name,'file') % if new file already exists, just delete it
    delete(file_name) % delete
end
end