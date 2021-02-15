function HK_tds_autolog()
%HK_AUTOLOG Creates logs for all the data
%   logs HK TDS data
%          DOESN'T WORK, (FIX TBD)

y0 = 2020;
m0 = 2;
y = year(date);
m = month(date)-1;
fm = 12;
dy = y-y0+1;
dm = m-m0+1;

if dy>1
    for i = y0:y
        if i == y
            fm = m;
        end
        for j=m0:fm
            HK_tds_monthly_log(j,i,'C:\Users\tform\OneDrive\Dokumenty\GitHub\Matlab_HK\include_mat\mycode\HK_TDS_monthly_logs')
        end
        m0 = 1;
    end
else 
    for i = m0:m
        HK_tds_monthly_log(i,y0,'C:\Users\tform\OneDrive\Dokumenty\GitHub\Matlab_HK\include_mat\mycode\HK_TDS_monthly_logs')
    end
    
end

