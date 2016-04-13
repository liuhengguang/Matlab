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


snr = -15;
EB_N0 = 1;
v_bbgc = 10^(-snr(EB_N0)/10);

Tpulse = 6;


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
[ ind_Rk, pulse_Tk, pulsek ] = algo_kalman( signal_noise, Fs, Tpulse );

%% Filtre 
[ ind_Rf1, pulse_Tf1, pulsef1, ind_Rf2, pulse_Tf2, pulsef2 ] = algo_filtre( signal_noise, Fs, Tpulse );

%% wavelet
[ind_Rw1, pulse_Tw1, pulsew1, ind_Rw2, pulse_Tw2, pulsew2, ...
ind_Rw3, pulse_Tw3, pulsew3 ] = algo_wavelet( signal_noise, Fs, Tpulse );
%%

figure, plot(ind_Rf1(2:end), pulsef1); 
hold all
plot(ind_Rf2(2:end), pulsef2)
plot(ind_Rk(2:end), pulsek)
plot(ind_Rw1(2:end), pulsew1)
plot(ind_Rw2(2:end), pulsew2)
plot(ind_Rw3(2:end), pulsew3)
legend('butter','cheby','kalman','W1','W2','W3')
title('Heart-Rate Obtention')

figure, plot(pulse_Tf1*10); 
hold all
plot(pulse_Tf2*10)
plot(pulse_Tk*10)
plot(pulse_Tw1*10)
plot(pulse_Tw2*10)
plot(pulse_Tw3*10)
legend('butter','cheby','kalman','W1','W2','W3')
title('Heart-Rate Obtention')