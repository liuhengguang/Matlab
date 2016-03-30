%% Algorithm 1: filtering for the detection of PPG, 
clear all
close all
clc

addpath(path);
%% Signal and data definitions
signal = load('Shimmer_E9E9_Int_Exp_A13_CAL.mat');
signal = signal.Shimmer_E9E9_Int_Exp_A13_CAL;
time = load('Shimmer_E9E9_Timestamp_Unix_CAL.mat');
time = time.Shimmer_E9E9_Timestamp_Unix_CAL;

Fs = 51.2; % sampling frequency

time = (time-time(1))*10^(-3)/60/60;

time_min = 1:floor(Fs*60):length(signal);


%% Bandpass filtering
[b1,a1] = butter(3,[0.02 0.08],'bandpass');
[b2,a2] = cheby2(5,30,[0.015 0.14],'bandpass');
signal_filt1 = filtfilt(b1,a1,signal);
signal_filt2 = filtfilt(b2,a2,signal);

figure,
pwelch(signal,[],[],[],Fs)
figure,
pwelch(signal_filt1,[],[],[],Fs)
figure,
pwelch(signal_filt2,[],[],[],Fs)

%% Detection of local peak per minutes

[ pouls_min1, ind_R1, R1 ] = detection_peack_min( signal_filt1, time_min );
[ pouls_min2, ind_R2, R2 ] = detection_peack_min( signal_filt2, time_min );

%% Results
time_hour = (0:length(pouls_min1)-1)/60;

figure
subplot 311
plot(time,signal)
xlabel('time in hour')
ylabel('PPG in mV')
title('signal of the PPG')
subplot 312 
plot(time_hour,pouls_min1)
xlabel('time in hour')
ylabel('heart rate')
title('Heart rate per minute obtained by Butterworth filter')
subplot 313 
plot(time_hour,pouls_min2)
xlabel('time in hour')
ylabel('Heart rate')
title('Heart rate per minute obtained by Chebyshev filter')



