function [fname] = findfullpath(files, keyword)
%FINDFULLPATH Looks for a file and returns full path.
fname = 0;
files = struct2cell(files);
for i = 3:(length(files))
    filename = char(files(1, i));
    filename = filename(1:15);
    if strcmp(filename, keyword)
        fname = [char(files(2,i)) '\' char(files(1,i))];
    end
end
end

