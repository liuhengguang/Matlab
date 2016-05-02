clear all
close all
clc

addpath(genpath('./functions'));
addpath(genpath('./signals'));
%% Signal and Data definitions
load('Etienne_25_04_Timestamp.mat')
load('Etienne_25_04_PPG.mat')
load('Etienne_25_04_ACCEL.mat')

Fs = 100.51; % sampling frequency
TimeBegin = 15*60*60+24*60+14; % Begin time of the recording

Timestamp = Etienne_25_04_Timestamp;
ACCEL = Etienne_25_04_ACCEL;
PPG = Etienne_25_04_PPG;

Timestamp = (Timestamp-Timestamp(1))*10^(-3)+TimeBegin;

TsmoothHR =60;

timeTsHR = [];
time_1min = [];
time_2min = [];

pulse_smooth = [];
respiratoryRate = [];
sleep = [];

figure,
subplot(211)
plot(Timestamp/60/60,ACCEL)
grid on; axis('tight'),
title('Accelerometer')
xlabel('time in Hour')
ylabel('Amplitude')
subplot(212)
plot(Timestamp/60/60,PPG)
grid on; axis('tight'),
title('PPG')
xlabel('time in Hour')
ylabel('Amplitude')

%% Stop wearing bracelet
[ index ] = unworkable_index( Fs, PPG );


for k=2:2:length(index)-1
    
    PPG_inter = PPG(index(k):index(k+1));
    ACCEL_inter = ACCEL(index(k):index(k+1),:);
    %% Heart Rate
    % Wavelet Decomposition
    % lev = wmaxlev(signal,'db5');
    % [thr,sorh,keepapp] = ddencmp('den','wv',signal);
    % xd3 = wdencmp('gbl',signal,'db5',real(lev),thr,sorh,keepapp);
    %
    % signal_wav = xd3;
    signal_wav = PPG_inter;
    
    % Band-pass filter
    Wn = 2*[0.5 3]/Fs;
    [b2,a2] = cheby2(3,30,Wn,'bandpass');
    signal_filt = filtfilt(b2,a2,signal_wav);
    
    
    % Peak Detection
    [ R, ind_R ] = detection_peack( signal_filt, Fs,Timestamp-TimeBegin , 0, 0, 0.2);
    % Heart Rate Obtention
    [ pulse_smooth_inter ] = heart_rate_smooth(ind_R, Fs, length(signal_filt), TsmoothHR);
    pulse_smooth = [pulse_smooth pulse_smooth_inter];
    
    timeTsHR_inter = 1:floor(Fs*TsmoothHR):length(PPG_inter);
    timeTsHR_inter = timeTsHR_inter./Fs+Timestamp(index(k))-1/Fs;
    timeTsHR = [timeTsHR timeTsHR_inter];
    
    %% Respiratory Rate
    [ respiratoryRate_inter ] = respiratory_rate2( PPG_inter, Fs );
    respiratoryRate = [respiratoryRate respiratoryRate_inter];
    
    time_1min_inter = 1:floor(Fs*60):length(PPG_inter);
    time_1min_inter = time_1min_inter./Fs+Timestamp(index(k))-1/Fs;
    time_1min = [time_1min time_1min_inter];
    
    %% Sleep Detection
    [ sleep_inter, rest_inter ] = sleep_detection( ACCEL_inter, Fs );
    sleep = [sleep sleep_inter];
    
    time_2min_inter = 1:floor(Fs*2*60):length(PPG_inter);
    time_2min_inter = time_2min_inter./Fs+Timestamp(index(k))-1/Fs;
    time_2min = [time_2min time_2min_inter];
end
%% Results
T = Timestamp(index)/60/60;

figure,
subplot(311)
plot(timeTsHR/60/60,pulse_smooth)
hold on
for k=1:length(index)
plot([T(k) T(k)],[min(pulse_smooth) max(pulse_smooth)],'-g','linewidth',2) 
end
grid on; axis('tight')
xlabel('time (hour)')
ylabel('Amplitude')
title('Heart rate')
subplot(312)
plot(time_1min/60/60,respiratoryRate)
hold on
for k=1:length(index)
plot([T(k) T(k)],[min(respiratoryRate) max(respiratoryRate)],'-g','linewidth',2) 
end 
grid on
axis('tight')
xlabel('time (hour)')
ylabel('Amplitude')
title('Respiratory Rate')
subplot(313)
plot(time_2min/60/60,sleep)
hold on
for k=1:length(index)
plot([T(k) T(k)],[min(sleep) max(sleep)],'-g','linewidth',2) 
end
axis('tight')
ylim([-0.3 1.3])
xlabel('time (hour)')
ylabel('Amplitude')
title('Sleep Detection')

