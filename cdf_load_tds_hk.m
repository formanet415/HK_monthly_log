function hk = cdf_load_tds_hk(fname)
%cdf_load_tds_hk Loads all the data in a single structure which is returned.
%Input: fname = Full path and cdf filename

%reading cdf
[cstr, cinfo] = tdscdf_load_roc_cdf_file(fname, 1, 0, '');

%picking values for structure
vars = cinfo.Variables(:,1);
validmin = cinfo.VariableAttributes.VALIDMIN;
validmax = cinfo.VariableAttributes.VALIDMAX;
fillval = cinfo.VariableAttributes.FILLVAL;
format = cinfo.VariableAttributes.FORMAT;
units = cinfo.VariableAttributes.UNITS;
varnotes = cinfo.VariableAttributes.VAR_NOTES;

%creating structure with data and adding picked values
hk = struct();
for i=1:length(vars)
    varname = vars{i};
    data = cstr{i};
    s = struct('data', data);
    vmin_i = tdscdf_find_cell_idx(validmin(:,1), varname);
    vmax_i = tdscdf_find_cell_idx(validmax(:,1), varname);
    fill_i = tdscdf_find_cell_idx(fillval(:,1), varname);
    form_i = tdscdf_find_cell_idx(format(:,1), varname);
    unit_i = tdscdf_find_cell_idx(units(:,1), varname);
    varn_i = tdscdf_find_cell_idx(varnotes(:,1), varname);
    if vmin_i ~= 0 
        s.VALIDMIN = validmin(vmin_i,2);
    end
    if vmax_i ~= 0
        s.VALIDMAX = validmax(vmax_i,2);
    end
    if fill_i ~= 0
        s.FILLVAL = fillval(fill_i,2);
    end
     if form_i ~= 0
        s.FORMAT = format(form_i,2);
     end
     if unit_i ~= 0
        s.UNITS = units(unit_i,2);
     end
     if unit_i ~= 0
        s.VARNOTES = varnotes(varn_i,2);
     end
    
    hk.(varname) = s;
end


end

