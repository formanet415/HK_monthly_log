function [ostr, datename] = tdscdf_load_hk_tds_log_data(fname, find_file)

rocstr = 'solo_HK_rpw-tds_';
skip_name_check = 1;

if ~exist('find_file','var') || isempty(find_file)
    find_file = 0;
end

[cstr, cinfo] = tdscdf_load_roc_cdf_file(fname, skip_name_check, find_file, rocstr);
%cinfo.Variables{:,1} 

ivar = tdscdf_find_var_idx(cinfo, 'ACQUISITION_TIME');
ostr.a_time = cstr{ivar}';
ivar = tdscdf_find_var_idx(cinfo, 'Epoch');
ostr.epoch = cstr{ivar}';
ivar = tdscdf_find_var_idx(cinfo, 'HK_TDS_TEMP_PCB');
ostr.temp_pcb = temperature(double(cstr{ivar}))';

ivar = tdscdf_find_var_idx(cinfo, 'HK_TDS_SNAPSHOT_CNT');
ostr.snap_cnt = double(cstr{ivar})';
ivar = tdscdf_find_var_idx(cinfo, 'HK_TDS_SNAPSHOT_MIN_Q_FACT');
ostr.snap_min_q = double(cstr{ivar})';
ivar = tdscdf_find_var_idx(cinfo, 'HK_TDS_SNAPSHOT_MAX_Q_FACT');
ostr.snap_max_q = double(cstr{ivar})';

ivar = tdscdf_find_var_idx(cinfo, 'HK_TDS_S_N_QUEUE');
ostr.snap_norm_queue = double(cstr{ivar})';
ivar = tdscdf_find_var_idx(cinfo, 'HK_TDS_S_S2_QUEUE');
ostr.snap_sbm2_queue = double(cstr{ivar})';

ivar = tdscdf_find_var_idx(cinfo, 'HK_TDS_MODE');
ostr.mode = double(cstr{ivar})';

ivar = tdscdf_find_var_idx(cinfo, 'HK_TDS_DPU_SPW_LINK_STATE');
ostr.dpu_spw_link = double(cstr{ivar})';

ivar = tdscdf_find_var_idx(cinfo, 'HK_TDS_RESET_CAUSE');
ostr.tds_rst_cause = double(cstr{ivar})';

ivar = tdscdf_find_var_idx(cinfo, 'HK_TDS_LE_CNT');
ostr.error_cnt_low = double(cstr{ivar})';
ivar = tdscdf_find_var_idx(cinfo, 'HK_TDS_ME_CNT');
ostr.error_cnt_med = double(cstr{ivar})';
ivar = tdscdf_find_var_idx(cinfo, 'HK_TDS_HE_CNT');
ostr.error_cnt_high = double(cstr{ivar})';
ivar = tdscdf_find_var_idx(cinfo, 'HK_TDS_LAST_ER_RID');
ostr.error_last_id = double(cstr{ivar})';
ivar = tdscdf_find_var_idx(cinfo, 'HK_TDS_LAST_ER_CODE');
ostr.error_last_code = double(cstr{ivar})';

ivar = tdscdf_find_var_idx(cinfo, 'HK_TDS_SW_PROCESS_ANOMALY');
ostr.error_cnt_sw_process_anomaly = double(cstr{ivar})';
ivar = tdscdf_find_var_idx(cinfo, 'HK_TDS_SW_ANOM_DETAIL');
ostr.error_sw_anomaly_detail = double(cstr{ivar})';

datename = '';
for i = length(rocstr)+1:length(fname)-4
    datename = append(datename, fname(i));    
end

return;

function c = temperature(n)
    logval = (4700/5000)*n./(4096-n);
    a = 1/298.15 + (1/3976)*log(logval);
    c = 1./a-273.15;
     
    return;

%iover = find(bitand(ostr.data,2^14));
%ostr.data(iover) = NaN; 

%deleted some stuff here. if something breaks try readding from tdscdf_load_hk_tds
