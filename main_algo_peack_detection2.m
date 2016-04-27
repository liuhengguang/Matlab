%% Algorithm 1: filtering for the detection of PPG, 
clear all
close all
clc

addpath(genpath('./functions'));
addpath(genpath('./signals'));

%% Signal and data definitions

signal = load('perfect_ppg.mat');
signal = signal.perfect_ppg;
time = load('time_perfect_ppg.mat');
time = time.time_perfect_ppg;
time = (time-time(1))*10^(-3);
Fs = 128; % sampling frequency


snr = -25;
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

signal_filt1 = filtfilt(b1,a1,signal_noise);

signal_filter = filter([1,2,-2,-1],1,signal_filt1);

signal_square = signal_filter.*signal_filter;

figure, plot(signal(1:2000))

figure, subplot(211); plot(signal_square(1:2000))
subplot(212); plot(signal(1:2000)-mean(signal(1:2000)))
axis('tight')