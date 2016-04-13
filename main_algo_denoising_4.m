% This main is using the three different methods to compare them. 
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
%% Kalman
[ ind_Rk, pulse_mink, pulsek ] = algo_kalman( signal_noise, Fs, Tpulse );

%% Filtre 
[ ind_Rf1, pulse_minf1, pulsef1, ind_Rf2, pulse_minf2, pulsef2 ] = algo_filtre( signal_noise, Fs, Tpulse );

%% wavelet
[ ind_Rw1, pulse_minw1, pulsew1, ind_Rw2, pulse_minw2, pulsew2, ...
ind_Rw3, pulse_minw3, pulsew3 ] = algo_wavelet( signal_noise, Fs, Tpulse );

%%

figure, plot(ind_Rf1(2:end), pulsef1/Fs); 
hold hall
plot(ind_Rf2(2:end), pulsef2/Fs)
plot(ind_Rk(2:end), pulsek/Fs)
plot(ind_Rw1(2:end), pulsew1/Fs)
plot(ind_Rw2(2:end), pulsew2/Fs)
plot(ind_Rw3(2:end), pulsew3/Fs)
legend('butter','cheby','kalman','W1','W2','W3')
title('Heart-Rate Obtention')