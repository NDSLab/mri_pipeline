function out = reshape_along_3rd(A)
% reshape_along_dim is used to reshape, e.g. a 3d array into a 2d array,
% where the wrapping is done along the 3rd dimension of the array
% Usage:
%   A(:,:,1) = magic(3); A(:,:,2) = magic(3)*2; 
%   B = reshape_along_dim(A)
% 

[n, m, p] = size(A); 

for i=1:p
    rowStart = (i - 1) * n + 1;
    rowEnd = i * n;
    out(rowStart:rowEnd,:) = A(:,:,i);
end

end