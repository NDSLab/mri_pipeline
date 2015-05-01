% use this simple script to combine data of multiple subjects, via the
% interactive torque matlab session 

subjects = [28:30];


for subject=subjects
    fprintf('\n====================================\n');
    fprintf('starting combining subject %d\n');
    t=tic;
    CombineSubject(subject);
    fprintf('\n subject %d data combined in: \n');
    toc(t)
    fprintf('\n====================================\n');
end