clear all
close all
clc

addpath(genpath('./functions'));
addpath(genpath('./signals'));
%% Signal and Data definitions

load('Gauthier_25_04_Timestamp.mat')
load('Gauthier_25_04_ACCEL.mat')
load('Gauthier_25_04_PPG.mat')

Fs = 100.51; % sampling frequency
TimeBegin = 12*60*60+40*60+59; % Begin time of the recording

Timestamp = Gauthier_25_04_Timestamp;
ACCEL = Gauthier_25_04_ACCEL;
PPG = Gauthier_25_04_PPG;

%%
Timestamp = (Timestamp-Timestamp(1))*10^(-3)+TimeBegin;

TsmoothHR =60;
timeTsHR = 1:Fs*TsmoothHR:length(PPG);
timeTsHR(end+1) = length(PPG);

time_1min = 1:Fs*60:length(PPG);
time_1min(end+1) = length(PPG);

time_2min = 1:Fs*2*60:length(PPG);
time_2min(end+1) = length(PPG);
%% Wavelet Decomposition
% lev = wmaxlev(signal,'db5');
% [thr,sorh,keepapp] = ddencmp('den','wv',signal);
% xd3 = wdencmp('gbl',signal,'db5',real(lev),thr,sorh,keepapp);
% 
% signal_wav = xd3;
signal_wav = PPG;
%% Band-pass filter
Wn = 2*[0.5 3]/Fs;
[b2,a2] = cheby2(3,30,Wn,'bandpass');
signal_filt = filtfilt(b2,a2,signal_wav);

figure,
pwelch(PPG,[],[],[],Fs)
figure,
pwelch(signal_filt,[],[],[],Fs)

%% Peak Detection
[ R, ind_R ] = detection_peack( signal_filt, Fs,Timestamp-TimeBegin , 0, 0, 0.2);

figure, plot(Timestamp/60/60,PPG-mean(PPG)); 
hold all
plot(Timestamp/60/60,signal_filt);
plot((ind_R+TimeBegin)/60/60,R,'x','linewidth',2)
grid on; axis('tight'),
legend('signal','signal filter','peak')
title('Peak Detection')
xlabel('time in Hour')
ylabel('Amplitude')
%% Heart Rate 
[ pulse_smooth ] = heart_rate_smooth(ind_R, Fs, length(signal_filt), TsmoothHR);

%% Respiratory Rate
[ respiratoryRate ] = respiratory_rate2( PPG, Fs );

%% Sleep Detection
[ sleep, rest ] = sleep_detection( ACCEL, Fs );
%% Results

figure, 
subplot(311)
plot((timeTsHR(1:end-1)/Fs+TimeBegin)/60/60,pulse_smooth)
grid on; axis('tight')
xlabel('time (hour)')
ylabel('Amplitude')
title('Heart rate')
subplot(312)
plot((time_1min(1:end-1)/Fs+TimeBegin)/60/60,respiratoryRate)
grid on
axis('tight')
xlabel('time (hour)')
ylabel('Amplitude')
title('Respiratory Rate')
subplot(313)
plot((time_2min(1:end-1)/Fs+TimeBegin)/60/60,sleep)
axis('tight')
ylim([-0.3 1.3])
xlabel('time (hour)')
ylabel('Amplitude')
title('Sleep Detection')

