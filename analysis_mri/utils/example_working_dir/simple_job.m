function simple_job(input)
fprintf('following input was received:\n')
disp(input)

jobinfo = get_jobinfo();
fprintf('this jobs id-number is %s\n',jobinfo.jobid);
if jobinfo.workingDir
    fprintf('working directory found: %s\n', jobinfo.workingDir);
    % write a single file, just to be sure epilogue can handle non-empty
    % folders
    fileName = [jobinfo.workingDir '/test.mat'];
    save(fileName)
    assert(exist(fileName,'file')==2,'test-file not written successfully');
else
    fprintf('no working directory found');
end


end