%% Algorithm 1: filtering for the detection of PPG, 
clear all
close all
clc

addpath(genpath('../functions'));
addpath(genpath('../signals'));

%% Signal and data definitions

signal = load('PPG_A13.mat');
signal = signal.PPG_A13(1:end/2);
time = load('Timestamp.mat');
time = time.Timestamp(1:end/2);
time = (time-time(1))*10^(-3);
Fs = 128; % sampling frequency


snr = -20;
EB_N0 = 1;
v_bbgc = 10^(-snr(EB_N0)/10);


% Generate original signal and a noisy version adding 
% a standard Gaussian white noise. 
signal_noise = signal+v_bbgc*randn(1,length(signal))';

figure, plot(time,signal_noise)
hold all
plot(time,signal), axis([0 120 -1000 4000])
xlabel('time (sec)')
ylabel('signal')
legend('signal','signal noise')

%% Bandpass filtering
Wn = 2*[0.5 3.5]/Fs;
[b1,a1] = butter(5,Wn,'bandpass');
Wn = 2*[0.5 3.5]/Fs;
[b2,a2] = cheby2(3,30,Wn,'bandpass');
signal_filt1 = filtfilt(b1,a1,signal_noise);
signal_filt2 = filtfilt(b2,a2,signal_noise);

figure,
pwelch(signal,[],[],[],Fs)
figure,
pwelch(signal_filt1,[],[],[],Fs)
figure,
pwelch(signal_filt2,[],[],[],Fs)

%% Detection of local peak per 10 sec

[ R1, ind_R1 ] = detection_peack( signal_filt1, Fs, time, 0, 0, 0.2);
[ R2, ind_R2 ] = detection_peack( signal_filt2, Fs, time, 0, 0, 0.2);

%% Pulse Detection
[ pulse_min1 ] = pulse_ppg( length(signal), 60, ind_R1, Fs);
[ pulse_min2 ] = pulse_ppg( length(signal), 60, ind_R2, Fs);
[ pulse1 ] = heart_rate(ind_R1);
[ pulse2 ] = heart_rate(ind_R2);

y_min = min(min(min(signal-mean(signal),signal_filt1),signal_filt2));
y_max = max(max(max(signal-mean(signal),signal_filt1),signal_filt2));

figure
plot(time/60,signal-mean(signal))
hold all
plot(time/60, signal_filt1)
plot(ind_R1/60,R1,'x','linewidth',2)
plot(time/60, signal_filt2)
plot(ind_R2/60,R2,'x','linewidth',2)
axis([0 time(end)/60 y_min y_max])
legend('signal','butter','Peack butter','cheby2','Peack cheby2')
xlabel('time in min')
ylabel('signal')
title('Peack detection of a PPG by using butter and cheby2 filter')

figure, 
plot(ind_R1(2:end),pulse1)
hold all
plot(ind_R2(2:end),pulse2)
legend('pulse butter','pulse cheby')
