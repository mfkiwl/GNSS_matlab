
% file=['SEPT_20181740000_01H_01S_MO.rnx']; % 2018
% xyzStation = [3655333.1790  1403901.2258  5018038.3565];
% measurementsInterval = 1;
% 
% [~, ~, observablesHeader, ~, timeFirst, timeLast, obsG, obsR, obsE, obsC, obsJ, obsI, obsS, slot]=readRinex302(file);
% [time(1), time(2), time(3), time(4)] = cal2gpstime(timeFirst);
% [~, ~, ~, gpsSecondsFirst] = cal2gpstime(timeFirst);
% [~, ~, ~, gpsSecondsLast] = cal2gpstime(timeLast);
% epoch = gpsSecondsFirst:measurementsInterval:gpsSecondsLast;
% sysDigit = [2]; % GPS=0, GLONASS=1, GALILEO=2, BEIDOU=3 --> choose systems
% 
% eph = readSp3(time, sysDigit);
% sysConst = ['E']; %inne systemy: 'G', 'R', 'C', 'E'
% sat_clk = readCLK(time, sysConst);
% bias = readBIA(time, sysConst);
% 
% 
% [obsTable, obsMatrix, obsType] = analysObs(epoch, observablesHeader, xyzStation, eval(['obs', sysConst]), sysConst);
% 

%% pozycja kodowa

% X = [3655333.1790  1403901.2258  5018038.3565; %SEPT
%     3655336.8160  1403899.0382  5018036.4527]; % SEP2
%  
% codes = ["C1C" "C5Q"]; % wybrane kody
time_interval = 100; % interwa� na jaki chcemy pozycje
system = 'E';
% data = ["2018-SEPT.mat" "2018-SEP2.mat"]; %wczytane dane dla odbiornik�w
% 
% [X_code1, DOP1, dtrec1, Az_EL_R1, tropo1, tau1] = codepos(X(1,:), codes, time_interval, system, data(1));
% [X_code2, DOP2, dtrec2, Az_EL_R2, tropo2, tau2] = codepos(X(2,:), codes, time_interval, system, data(2));
% 
% d = X_code1 - X_code2
% 
%% odl przybli�ona po uwzgl�dnieniu poprawki zegara odbiornika
% 
% [ro_approx1, du1] = ro_approx(X_code1, dtrec1, tau1, data(1));
% [ro_approx2, du2] = ro_approx(X_code2, dtrec2, tau2, data(2));
% % 
% dro = squeeze(ro_approx1(1,3,:)) - squeeze(Az_EL_R1(1,5,:)); %r�znica mi�dzy odl z kodowego a przybli�on� dla odb1 sat1
% 
%% pojedyncze r�nice
const;
obs_types = ["C1C" "L1C" "C6C" "L6C" "C5Q" "L5Q" "C7Q" "L7Q" "C8Q" "L8Q"]; % wyb�r obserwacji do r�nic
phase_freq = [fE1 fE6 fE5 fE7 fE8];
data = 'data_all.mat';
% [single_diff] = single_differences_obs(time_interval, obs_types, system, obsMatrix1, obsMatrix2, Az_EL_R1, data);
% 
% single_diff_range1 = single_diff_range(time_interval, ro_approx1, ro_approx2, Az_EL_R1, data);

% single_diff_tropo = single_diff_range(time_interval, tropo1, tropo2, Az_EL_R1, data);

% single_diff_dux = single_diff_u(time_interval, du1, du2, Az_EL_R1,1, data);
% single_diff_duy = single_diff_u(time_interval, du1, du2, Az_EL_R1,2, data);
% single_diff_duz = single_diff_u(time_interval, du1, du2, Az_EL_R1,3, data);

%% podw�jne r�znice

% double_diff = double_differences(single_diff, length(obs_types), 7);
% 
% double_diff_range = double_differences(single_diff_range, 1, 7);
% double_diff_range = repmat(double_diff_range, length(obs_types), 1);

% double_diff_tropo = double_differences(single_diff_tropo, 1, 7);
% double_diff_tropo = repmat(double_diff_tropo, length(obs_types), 1);

% podw�jne r�nice wersor�w do macierzy A
% double_diff_dux = double_differences(single_diff_dux, 1, 7);
% double_diff_dux = repmat(double_diff_dux, length(obs_types), 1);
% 
% double_diff_duy = double_differences(single_diff_duy, 1, 7);
% double_diff_duy = repmat(double_diff_duy, length(obs_types), 1);
% 
% double_diff_duz = double_differences(single_diff_duz, 1, 7);
% double_diff_duz = repmat(double_diff_duz, length(obs_types), 1);

%% model stochastyczny 

n_obs = 10;
epochs = gpsSecondsFirst:time_interval:gpsSecondsLast;
C = C_matrix(Az_EL_R1, Az_EL_R2, time_interval, phase_freq, data);
Cl = Cl_matrix(C, phase_freq, time_interval, data);

