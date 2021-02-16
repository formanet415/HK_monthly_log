function HK_tds_monthly_log(month, year, inputDIR, outputDIR)
%HK_TDS_MONTHLY_LOG Logs the errors and mode changes of the TDS instrument
%   month     number of month         ex: 8
%   year      number of year          ex: 2020
%   inputDIR  path to HK data         ex: 'Z:\rpw\HK'
%   outputDIR path to HK data         ex: 'D:\HK_logs' (the directory has to exist)
if ~exist(inputDIR, 'dir')
    error('Input dir does not exist');
    return
end
if ~exist(outputDIR, 'dir')
    error('Output dir does not exist');
    return
end
addpath(pwd);
if inputDIR(end) ~= filesep
    inputDIR = [inputDIR filesep];
end
%   LOADING HK CDF FILE
logs = string(['%' sprintf('HK - modes and errors for %4i/%02i', month, year)]);
load('tempfit.mat');

%   VALUES NEEDED FOR LOGS INTERPRETATION
LRID = 65535;
LCODE = 255;
LMODE = 255;
LREJC = 0;
MOD = table2cell(readtable('modes.csv'));

days = struct2cell(dir([inputDIR filesep num2str(year) filesep num2str(month,'%02.f') ]));
days = days(1,3:end);

Epoch = [];
PCB_Temperature = [];
FPGA_Temperature = [];
SRAM_Temperature = [];
%SW Performance
SW_MAX_LOOP_TIME = [];
SW_PR_PKTS_IN_QUEUE = [];
SW_PKTS_IN_QUEUE = [];
SW_LOOP_ITERATIONS = [];
SW_PROCESS_TIME = [];
SW_IDLE_TIME = [];

TDS_MODE = [];
%Snapshot Statistics
SNAPSHOT_CNT = [];
SNAPSHOT_MAX_Q_FACT = [];
SNAPSHOT_MIN_Q_FACT = [];
S_N_QUEUE = [];
S_S2_QUEUE = [];

for i=days    % BROWSING DAYS IN MONTH
    fPath = dir(fullfile(inputDIR,sprintf('%4i/%02i/%02i/solo_HK_rpw-tds*',year,month,str2double(i))));
    if size(fPath) == [1,1]
    	fname = fullfile(fPath.folder, fPath.name);
    elseif size(fPath) == [0,1]
        disp(['file not found: ' fullfile(inputDIR,sprintf('%4i/%02i/%02i/solo_HK_rpw-tds*',year,month,str2double(i)))])
        continue
    elseif length(fPath) > 1
        disp('multiple files found, choosing highest version')
        names = struct2cell(fPath);
        names = names(1,:);
        version = [];
        for j=1:length(names)
            name = char(names(j));
            Vindex = strfind(name, 'V');
            version(j) = str2num(name(Vindex+1:Vindex+2));
        end
        if sum(max(version) == version) == 1
            fname = fullfile(fPath.folder, char(names(max(version) == version)));
        else
            disp('choosing failed, multiple files with same version')
        end
    end
            
    
    %   GATHERING TEMPERATURE DATA
    
    if exist(fname, 'file')
       
        hk = cdf_load_tds_hk(fname);
        Epoch = [Epoch; hk.Epoch.data];
        PCB_Temperature = [PCB_Temperature; tempfit(hk.HK_TDS_TEMP_PCB.data)];
        FPGA_Temperature = [FPGA_Temperature; tempfit(hk.HK_TDS_TEMP_FPGA.data)];
        SRAM_Temperature = [SRAM_Temperature; tempfit(hk.HK_TDS_TEMP_SRAM.data)];
        SW_MAX_LOOP_TIME = [SW_MAX_LOOP_TIME; hk.HK_TDS_SW_MAX_LOOP_TIME.data];
        SW_PR_PKTS_IN_QUEUE = [SW_PR_PKTS_IN_QUEUE; hk.HK_TDS_SW_PR_PKTS_IN_QUEUE.data];
        SW_PKTS_IN_QUEUE = [SW_PKTS_IN_QUEUE; hk.HK_TDS_SW_PKTS_IN_QUEUE.data];
        SW_LOOP_ITERATIONS = [SW_LOOP_ITERATIONS; hk.HK_TDS_SW_LOOP_ITERATIONS.data];
        SW_PROCESS_TIME = [SW_PROCESS_TIME; hk.HK_TDS_SW_PROCESS_TIME.data];
        SW_IDLE_TIME = [SW_IDLE_TIME; hk.HK_TDS_SW_IDLE_TIME.data];
        TDS_MODE = [TDS_MODE; hk.HK_TDS_MODE.data];
        SNAPSHOT_CNT = [SNAPSHOT_CNT; hk.HK_TDS_SNAPSHOT_CNT.data];
        SNAPSHOT_MAX_Q_FACT = [SNAPSHOT_MAX_Q_FACT; hk.HK_TDS_SNAPSHOT_MAX_Q_FACT.data];
        SNAPSHOT_MIN_Q_FACT = [SNAPSHOT_MIN_Q_FACT; hk.HK_TDS_SNAPSHOT_MIN_Q_FACT.data];
        S_N_QUEUE = [S_N_QUEUE; hk.HK_TDS_S_N_QUEUE.data];
        S_S2_QUEUE = [S_S2_QUEUE; hk.HK_TDS_S_S2_QUEUE.data];
        time = spdfencodett2000(hk.Epoch.data, 'Format', 3);
        
        %   SAVING LOGS (CHANGES IN MODES, ERRORS) FOR EACH DAY TO VARIABLE LOGS
        for j=1:length(hk.Epoch.data)
            if LMODE ~= hk.HK_TDS_MODE.data(j)
                [mess, logtime] = HK_log_change(hk.HK_TDS_MODE.data(j), MOD, j, time, 3);
                LMODE = hk.HK_TDS_MODE.data(j);
                logs(length(logs)+1) = strtrim([logtime, mess]);
            end
            if LCODE ~= hk.HK_TDS_LAST_ER_CODE.data(j)
                [mess, logtime] = HK_log_change([hk.HK_TDS_LAST_ER_RID.data(j) hk.HK_TDS_LAST_ER_CODE.data(j) hk.HK_TDS_SW_ANOM_DETAIL.data(j)], 'none', j, time, 1);
                LCODE = hk.HK_TDS_LAST_ER_CODE.data(j);
                logs(length(logs)+1) = strtrim([logtime, mess]);
            end
            if LREJC ~= hk.HK_TDS_REJ_TC_CNT.data(j)
                [mess, logtime] = HK_log_change([hk.HK_TDS_REJ_TC_CNT.data(j) hk.HK_TDS_LAST_REJ_TC_ID.data(j) hk.HK_TDS_LAST_REJ_TC_TYPE.data(j) hk.HK_TDS_LAST_REJ_TC_SUBTYPE.data(j)],'none', j, time, 4);
                LREJC = hk.HK_TDS_REJ_TC_CNT.data(j);
                logs(length(logs)+1) = strtrim([logtime, mess]);
            end
        end
    end
end
if isempty(Epoch)
    return;
end
% PLOTTING THE TEMPERATURE DATA
fig = figure('Position', [100, 100, 1400, 1100]);
subplot(3,1,1)
plot(Epoch, PCB_Temperature);
datetick('x','dd');
hold on;
plot(Epoch,FPGA_Temperature);
plot(Epoch,SRAM_Temperature);
xlim([Epoch(1) Epoch(length(Epoch))]) 
legend('PCB', 'FPGA', 'SRAM');
title(['HK temperature ' num2str(month) '-' num2str(year)])
xlabel('Time [day]');
ylabel(['Temperature [' char(176) 'C]']);

subplot(3,1,2)

plot(Epoch, SW_PR_PKTS_IN_QUEUE);
datetick('x','dd');
hold on;
plot(Epoch,SW_PKTS_IN_QUEUE);
xlim([Epoch(1) Epoch(length(Epoch))]) 
legend('SW_PR_PKTS_IN_QUEUE', 'SW_PKTS_IN_QUEUE', 'Interpreter','none');
title(['HK SW Performance ' num2str(month) '-' num2str(year)])
xlabel('Time [day]');
ylabel('Number of packets');

subplot(3,1,3)

plot(Epoch, SW_IDLE_TIME);
datetick('x','dd');
hold on;
plot(Epoch,SW_LOOP_ITERATIONS);
plot(Epoch,SW_MAX_LOOP_TIME);
plot(Epoch,SW_PROCESS_TIME);
modeval = 1.2*max([max(SW_IDLE_TIME), max(SW_LOOP_ITERATIONS), max(SW_MAX_LOOP_TIME), max(SW_PROCESS_TIME)]);
usedmodes = unique(TDS_MODE);
n = histcounts(TDS_MODE,[usedmodes;256]);
[n,idx] = sort(n, 'descend');
usedmodes = usedmodes(idx);
maxmod = 3;
if length(usedmodes)<3
    maxmod = length(usedmodes);
end
strmod = strings(3);
for i = 1:maxmod
    indxOfM = cellfun(@(x)isequal(x,usedmodes(i)),MOD(:,2));
    indxOfM = find(indxOfM);
    strmod(i) = char(MOD(indxOfM,1));
    c = ['m','g','r'];
    scatter(Epoch(TDS_MODE==usedmodes(i)), uint32(TDS_MODE(TDS_MODE==usedmodes(i))+1)*(modeval/uint32(1+usedmodes(i))), c(i), 'filled')
end

xlim([Epoch(1) Epoch(length(Epoch))]) 
legend('SW_IDLE_TIME', 'SW_LOOP_ITERATIONS', 'SW_MAX_LOOP_TIME', 'SW_PROCESS_TIME', strmod(1), strmod(2), strmod(3), 'Interpreter','none','Location','southoutside','Orientation','horizontal');
title(['HK SW Performance ' num2str(month) '-' num2str(year)])
xlabel('Time [day]');



set(fig,'Units','Inches');
pos = get(fig,'Position');
set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
oFilePath=fullfile(outputDIR, sprintf('HK_log_%02i-%4i.pdf',month, year));
delete(oFilePath)
print(fig, oFilePath, '-dpdf','-r0')    %CLOSE PDFs BEFORE RUNNING CODE
close(fig)

fig = figure('Position', [100, 100, 1400, 1100]);
subplot(3,1,1);
[Epo, SNAPSHOT_CNT] = HK_cleaner(SNAPSHOT_CNT, Epoch, hk.HK_TDS_SNAPSHOT_CNT.VALIDMAX);
plot(Epo, SNAPSHOT_CNT);
hold on;
datetick('x','dd');
xlim([Epoch(1) Epoch(length(Epoch))]) 
legend('SNAPSHOT_CNT', 'Interpreter','none');
title(['HK snapshot statistics ' num2str(month) '-' num2str(year)])
xlabel('Time [day]');
ylabel('number of snapshots');

subplot(3,1,2);

[Epo, SNAPSHOT_MAX_Q_FACT] = HK_cleaner(SNAPSHOT_MAX_Q_FACT, Epoch, hk.HK_TDS_SNAPSHOT_CNT.VALIDMAX);
yyaxis left
plot(Epo, SNAPSHOT_MAX_Q_FACT);
datetick('x','dd');
hold on;
ylabel('Character of snapshot queue');

yyaxis right
[Epo, SNAPSHOT_MIN_Q_FACT] = HK_cleaner(SNAPSHOT_MIN_Q_FACT, Epoch, hk.HK_TDS_SNAPSHOT_CNT.VALIDMAX);
plot(Epo, SNAPSHOT_MIN_Q_FACT);

legend('SNAPSHOT_MAX_Q_FACT', 'SNAPSHOT_MIN_Q_FACT', 'Interpreter','none');
title(['HK SW Q Factor ' num2str(month) '-' num2str(year)])
xlabel('Time [day]');

subplot(3,1,3);

scatter(Epoch, S_N_QUEUE);
datetick('x','dd');
hold on;
scatter(Epoch,S_S2_QUEUE, 'filled');
modeval = 1.2*max([max(S_N_QUEUE), max(S_S2_QUEUE)]);
usedmodes = unique(TDS_MODE);
n = histcounts(TDS_MODE,[usedmodes;256]);
[n,idx] = sort(n, 'descend');
usedmodes = usedmodes(idx);
maxmod = 3;
if length(usedmodes)<3
    maxmod = length(usedmodes);
end
strmod = strings(3);
for i = 1:maxmod
    indxOfM = cellfun(@(x)isequal(x,usedmodes(i)),MOD(:,2));
    indxOfM = find(indxOfM);
    strmod(i) = char(MOD(indxOfM,1));
    c = ['m','g','r'];
    scatter(Epoch(TDS_MODE==usedmodes(i)), uint32(modeval)*uint32(TDS_MODE(TDS_MODE==usedmodes(i))+1)/uint32(1+usedmodes(i)), c(i), 'filled')
end

xlim([Epoch(1) Epoch(length(Epoch))]) 
legend('S_N_QUEUE', 'S_S2_QUEUE', strmod(1), strmod(2), strmod(3), 'Interpreter','none','Location','southoutside','Orientation','horizontal');
title(['HK snapshot queue statistics ' num2str(month) '-' num2str(year)])
xlabel('Time [day]');
ylabel('Snapshots in queue');

set(fig,'Units','Inches');
pos = get(fig,'Position');
set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
oFilePathap=fullfile(outputDIR, sprintf('.HK_log_%02i-%4iap.pdf',month, year));
print(fig,oFilePathap, '-dpdf','-r0');    %CLOSE PDFs BEFORE RUNNING CODE
close(fig)
append_pdfs(oFilePath, oFilePathap)
delete(oFilePathap)



%   CREATES PDFS WITH HK LOGS 60 LINES PER PDF
lines = 60;
for i = 0:ceil(length(logs)/lines)-1
    fh = figure;
    ah = axes('parent',fh,'position',[0,0,1,1],'visible','off',...
          'xlim',[0,1],'ylim',[0,40],'ydir','reverse',...
          'fontsize',14);
    for j=(1:lines)
        if i*lines + j <= length(logs)
            text(0.01,40*j/lines,logs(i*lines + j),'parent',ah,'Interpreter','none');
        end
    print(fh,'-dpdf','-fillpage',oFilePathap)
    end
    close(fh)
    append_pdfs(oFilePath, oFilePathap)
    delete(oFilePathap)
end

end

function [t, d] = HK_cleaner(data, epoch, VALIDMAX) %Function to get values to plot without invalid values
    d = data(data<=VALIDMAX{1});
    t = epoch(data<=VALIDMAX{1});
end
