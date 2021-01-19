function [mess, logtime] = HK_log_change(DATA, list, index, time, type)
%HK_LOG_CHANGE Properly logs a change based upon the inputs, returns the log
if type == 1
    ER_C = readtable('err_codes.csv');
    ER_R = readtable('err_rid.csv');
    ER_C = table2cell(ER_C);
    ER_R = table2cell(ER_R);
    
    code_i = DATA(2);
    rid_i = DATA(1);
    det = num2str(DATA(3));
    
    indxOfC = cellfun(@(x)isequal(x,code_i),ER_C(:,2));
    indxOfC = find(indxOfC);
    
    indxOfR = cellfun(@(x)isequal(x,rid_i),ER_R(:,2));
    indxOfR = find(indxOfR);
    mess = ['--ERROR--' char(ER_R(indxOfR,1)) '--' char(ER_C(indxOfC,1)) ':' char(ER_C(indxOfC,3)) '-' det];
    logtime = strrep(time(index,:),'-',':');
end
if type == 3 
    indxOfER = cellfun(@(x)isequal(x,DATA),list(:,2));
    indxOfER = find(indxOfER);
    mess = ['--MODE--' char(list(indxOfER,1))  ];
    logtime = strrep(time(index,:),'-',':');
end
if type == 4 
    mess = ['--REJ--CNT-' num2str(DATA(1)) '-ID-' num2str(DATA(2)) '-TYPE-' num2str(DATA(3)) '-SUBTYPE-' num2str(DATA(4))];
    logtime = strrep(time(index,:),'-',':');
end
end

