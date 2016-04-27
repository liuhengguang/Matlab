%% Algorithm: pic detection on a clean PPG, 
clear all
close all
clc

addpath(genpath('../functions'));
addpath(genpath('../signals'));

%% Signal and data definition
signal = load('PPG_A13.mat');
signal = signal.perfect_ppg(1:floor(end/2));
time = load('Timestamp.mat');
time = time.time_perfect_ppg(1:floor(end/2));
time = (time-time(1))*10^(-3);

Fs = 128; % sampling frequency

time_min = 1:floor(Fs*60):length(signal);

%% Peack Detection

ind_R = [];
R = [];

signal_filter = filter([2,1,0,-1,-2],1,signal);

threshold = signal_filter>0;
signal_filter = signal_filter.*threshold;

time_5S = 1:floor(Fs*5):length(signal);

for p = 1:length(time_5S)-1
    x = signal_filter(time_5S(p):time_5S(p+1));
    [R_inter, ind_R_inter] = findpeaks(x,Fs,'MinPeakDistance',60/220,'MinPeakHeight',2*mean(x));

    ind_R_inter = ind_R_inter+time(time_5S(p));
    ind_R = [ind_R ;ind_R_inter];
    R = [R; R_inter];
end
ind_R = ind_R(2:end);
R = R(2:end);

%% Pulse Obtention
[ pulse ] = pulse_ppg( length(signal), 30 ,ind_R, Fs);
%% Result

figure,
plot(time/60,signal-mean(signal))
hold on
plot(time(6:end)/60,signal_filter(6:end)),
plot(ind_R/60, R,'gx','linewidth',2), 
axis('tight')
legend('signal norm','signal filter', 'Peack Detection')
xlabel('time in sec')
ylabel('signal')
title('Peack detection of a PPG')

[ pulse ] = heart_rate(ind_R);
figure, plot(ind_R(2:end)/60,pulse)