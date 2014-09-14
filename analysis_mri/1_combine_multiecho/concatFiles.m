function out = concatFiles(inCell)
% inCell is a cell array where each entry is a matrix of characters,
% containing filenames - sorted by echo (3rd dim).
% this function creates one output matrix (adapted for size) where all
% entries of the cell array are concatenated, while keeping 'sorting' by
% echoes

% collect all sizes of the entries of cell-array
for i=1:length(inCell)
   sizes(i,:)=size(inCell{i}); % dim(1)=nr of files; dim(2)=nr of chars; dim(3)=nr of echoes
end

% pick largest entry dimensions for output
out = char(zeros(sum(sizes(:,1)),max(sizes(:,2)),max(sizes(:,3))));

% and copy content to output matrix
offset = 0;
for i=1:length(inCell)
    tmp = inCell{i};
    
    out((offset+1):(sizes(i,1)+offset),1:sizes(i,2),:) = tmp;
    offset = offset + sizes(i,1);
end

end