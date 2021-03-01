function ivar = tdscdf_find_var_idx(cinfo, VarName)

ivar = 0;
for i=1:length(cinfo.Variables)
    if (strcmp(cinfo.Variables{i}, VarName))
        ivar = i;
        break;
    end
end
