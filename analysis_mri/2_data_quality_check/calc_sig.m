function [sig,msig] = calc_sig(P)
% Calculate the global signal (mean intensity per image)
global defaults;
if isempty(defaults) || ~isfield(defaults,'analyze') ||...
         ~isfield(defaults.analyze,'flip')
     defaults.analyze.flip = 0;
end

fprintf('\n\t\tLoading the selected files...');
V = spm_vol(P);
fprintf(' done');

sig = zeros(length(V),V{1}.dim(3));
msig = zeros(length(V),1);
%spm_progress_bar('Init',length(sig),'check global signal','images completed');
fprintf('\n\t\tCalculating the global signal from images:');
fprintf('\n\t\t1    ');
for i = 1:length(sig),
    for z = 1:V{i}.dim(3),
        img   = spm_slice_vol(V{i},...
            spm_matrix([0 0 z]),V{i}.dim(1:2),0);
        sig(i,z) = sum(img(:))/prod(V{1}.dim(1:2));
        msig(i) = msig(i) + sum(img(:));
    end;
    msig(i) = msig(i)/prod(V{1}.dim(1:3));
    %spm_progress_bar('Set',i);
    fprintf('.');
    if rem(i,50)==0
        fprintf('\n\t\t');
        fprintf('%d ',i);
        if i < 10; fprintf(' '); end;
        if i < 100; fprintf(' '); end;
        if i < 1000; fprintf(' '); end;
    end
end