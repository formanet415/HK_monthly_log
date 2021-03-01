function [cstr, cinfo, fname] = tdscdf_load_roc_cdf_file(fname, skip_name_check, find_file, rocstr)

l2_calba = 1;
%homedir = getenv('HOME');
%roc_dir = fullfile(homedir,'data/tds/cdf');
roc_dir = fullfile('/data/solo/tds/calba');
%roc_dir = '/mnt/alenka/tds/CDF/fm_data';

if (length(fname) == 1)
    [yy,mm,dd] = datevec(fname);
    find_file = 1;
    if (contains(rocstr,'HK'))
        fname = fullfile(roc_dir, sprintf('HK/%04d/%02d/%02d',yy,mm,dd));
    elseif (contains(rocstr,'L2'))
            if (contains(rocstr,'tds-surv-stat'))
                fname = fullfile(roc_dir, sprintf('L2/tds_stat/%04d/%02d',yy,mm));
            elseif (contains(rocstr,'tds-surv-tswf') || contains(rocstr,'tds-surv-rswf'))
                fname = fullfile(roc_dir, sprintf('L2/tds_wf_e/%04d/%02d',yy,mm));
            elseif (contains(rocstr,'tds-surv-mamp'))
                fname = fullfile(roc_dir, sprintf('L2/tds_mamp/%04d/%02d',yy,mm));
            elseif (contains(rocstr,'tnr-surv'))
                fname = fullfile(roc_dir, sprintf('L2/thr/%04d/%02d',yy,mm));
            elseif (contains(rocstr,'hfr-surv'))
                fname = fullfile(roc_dir, sprintf('L2/thr/%04d/%02d',yy,mm));
            end
    elseif (contains(rocstr,'L1R'))
        fname = fullfile(roc_dir, sprintf('L1R/%04d/%02d/%02d',yy,mm,dd));
    else
        fname = fullfile(roc_dir, sprintf('L1/%04d/%02d/%02d',yy,mm,dd));
    end
    datumstr = sprintf('_%02d%02d%02d_V',yy,mm,dd);
end

cstr = [];
cinfo = [];
curver = -1;
% Directory name specified, find file
if (find_file)
    fdir = fname;
    fname = [];
    files = dir(fdir);
    for idx=1:length(files)
        nm = files(idx).name;
        if (contains(nm, rocstr) && contains(nm,datumstr))
            ll = length(nm);
            version = str2num(nm((ll-5):(ll-4)));
            if (version > curver)
                fname = nm;
            else
                curver = version;
            end
        end
    end
    if isempty(fname)
        fprintf(1,'Matching TDS CDF file not found\n');
        return;
    else
        fprintf(1,'Found: %s\n', fname);
        fname = fullfile(fdir, fname);
    end
end

if (0 == skip_name_check)
%    rocstr = 'solo_L1_rpw-tds-surv-rswf_';
    if (0 == contains(fname, rocstr))
        fprintf(1,'Warning: file name not in standard format\n');
    end
end

[cstr, cinfo] = spdfcdfread(fname);

if (0 == skip_name_check)
    fprintf(1,'Loaded: %s\n', cinfo.GlobalAttributes.Logical_file_id{1});
    patidx = strfind(cinfo.GlobalAttributes.Logical_file_id{1}, rocstr);
    if (isempty(patidx))
        fprintf(1,'Error: file_id does not match specified product product\n');
        %return;
    end

    fprintf(1,'Data version: %s, Skeleton version: %s, pipeline version: %s\n', ...
        cinfo.GlobalAttributes.Data_version{1}, ...
        cinfo.GlobalAttributes.Skeleton_version{1}, ...
        cinfo.GlobalAttributes.Pipeline_version{1});
end
