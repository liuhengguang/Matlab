% This main is using the three different methods to compare them. 
clear all
close all
clc

addpath(genpath('../functions'));
addpath(genpath('../signals'));

%% Signal and data definitions

signal = load('PPG_A13.mat');
signal = signal.PPG_A13;
time = load('Timestamp.mat');
time = time.Timestamp ;
time = (time-time(1))*10^(-3);
Fs = 128; % sampling frequency


snr = -1;
EB_N0 = 1;
v_bbgc = 10^(-snr(EB_N0)/10);

% Generate original signal and a noisy version adding 
% a standard Gaussian white noise. 
noise = v_bbgc*randn(1,length(signal))';
signal_noise = signal+noise;

Tpulse = 6;

figure, plot(time/60/60,signal)
axis('tight')
xlabel('time (hour)')
ylabel('Amplitude')
title('signal')

Wn = 2*[0.5 3.5]/Fs;
[b1,a1] = butter(5,Wn,'bandpass');

signal_filt1 = filtfilt(b1,a1,signal_noise);

signal_filter = filter([1,2,-2,-1],1,signal_filt1);

signal_square = signal_filter.*signal_filter;
%% Kalman
[ ind_Rk, pulse_Tk, pulsek ] = algo_kalman( signal, Fs, Tpulse );

%% Filtre 
[ ind_Rf1, pulse_Tf1, pulsef1, ind_Rf2, pulse_Tf2, pulsef2 ] = algo_filtre( signal, Fs, Tpulse );

%% wavelet
[ind_Rw1, pulse_Tw1, pulsew1, ind_Rw2, pulse_Tw2, pulsew2, ...
ind_Rw3, pulse_Tw3, pulsew3 ] = algo_wavelet( signal, Fs, Tpulse );
%%

figure, 
plot(ind_Rf1(2:end), pulsef1);
hold all
plot(ind_Rf2(2:end), pulsef2)
plot(ind_Rk(2:end), pulsek)
plot(ind_Rw1(2:end), pulsew1)
plot(ind_Rw2(2:end), pulsew2)
plot(ind_Rw3(2:end), pulsew3)
legend('butter','cheby','kalman','W1','W2','W3')
title('Heart-Rate Obtention')
