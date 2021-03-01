function ivar = tdscdf_find_cell_idx(cinfo, VarName)

ivar = 0;
for i=1:length(cinfo)
    if (strcmp(cinfo{i}, VarName))
        ivar = i;
        break;
    end
end
