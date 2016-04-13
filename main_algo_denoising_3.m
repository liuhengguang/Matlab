%% Algorithm 3: Using the wavelet decomposition for the denoising of PPG, 
clear all
close all
clc

addpath(genpath('./functions'));
addpath(genpath('./signals'));

%% Signal and data definition
signal = load('perfect_ppg.mat');
signal = signal.perfect_ppg;
time = load('time_perfect_ppg.mat');
time = time.time_perfect_ppg;
time = (time-time(1))*10^(-3);

snr = -15;
EB_N0 = 1;
v_bbgc = 10^(-snr(EB_N0)/10);
Fs = 128; % sampling frequency

% Generate original signal and a noisy version adding 
% a standard Gaussian white noise.
noise = v_bbgc*randn(1,length(signal))';
signal_noise = signal+noise;

figure, plot(time,signal_noise)
hold all
plot(time,signal), axis([0 120 -1000 4000])
xlabel('time (sec)')
ylabel('signal')
legend('signal','signal noise')
%% Wavelet Decomposition
% using the matlab function wden


figure,
subplot(411), plot(time,signal), axis([0 120 800 2600]); 
title('Original signal'); 
 
lev = wmaxlev(signal_noise,'db5');
% decomposition. 
[c,l] = wavedec(signal_noise,lev,'db5');
 
% threshold the decomposition structure [c,l].
xd1 = wden(c,l,'sqtwolog','s','sln',lev,'db5');

% Plot signal. 
subplot(412), plot(time,xd1), axis([0 120 800 2600]);
title('De-noised signal - by decomposition c,l');

% 'mln' for rescaling done using level-dependent estimation of level noise
lev = wmaxlev(signal_noise,'sym8');
xd2 = wden(signal_noise,'modwtsqtwolog','s','mln',lev,'sym8');

subplot(413), plot(time,xd2), axis([0 120 800 2600]);
title('level-dependent estimation of level noise');

lev = wmaxlev(signal_noise,'db3');
[thr,sorh,keepapp] = ddencmp('den','wv',signal_noise);
xd3 = wdencmp('gbl',signal_noise,'db3',lev,thr,sorh,keepapp);
subplot(414), plot(time,xd3), axis('tight');
title('using wdencmp');
%% Derivating the signal
x = xd1;
windowSize = 15;
b1 = (1/windowSize)*ones(1,windowSize);
a1 = 1;

b2 = [2,1,0,-1,-2];
a2 = 1;
filter_size = length(b2);

signal_filt1 = filtfilt(b1,a1,x);
signal_filter1 = filter(b2,a2,signal_filt1);

x = xd2';
signal_filt2 = filtfilt(b1,a1,x);
signal_filter2 = filter(b2,a2,signal_filt2);

x = xd3;
signal_filt2 = filtfilt(b1,a1,x);
signal_filter3 = filter(b2,a2,signal_filt1);
%% Peack Detection
[ R1, ind_R1 ] = detection_peack( signal_filter1, Fs, time, 0, 0.68, 0.2);
[ R2, ind_R2 ] = detection_peack( signal_filter2, Fs, time, 0, 0.68, 0.2);
[ R3, ind_R3 ] = detection_peack( signal_filter3, Fs, time, 0, 0.68, 0.2);

%% Pulse Obtention
[ pulse_min1 ] = pulse_ppg( length(signal), 30 ,ind_R1, Fs);
[ pulse_min2 ] = pulse_ppg( length(signal), 30 ,ind_R2, Fs);
[ pulse_min3 ] = pulse_ppg( length(signal), 30 ,ind_R3, Fs);

[ pulse1 ] = heart_rate(ind_R1);
[ pulse2 ] = heart_rate(ind_R2);
[ pulse3 ] = heart_rate(ind_R3);

figure,
plot(time/60,signal-mean(signal))
hold on
plot(time(filter_size*2:end)/60,signal_filter1(filter_size*2:end))
plot(ind_R1/60, R1,'x','linewidth',2),
plot(time(filter_size*2:end)/60,signal_filter2(filter_size*2:end))
plot(ind_R2/60, R2,'x','linewidth',2),
plot(time/60,signal_filter3)
plot(ind_R3/60, R3,'x','linewidth',2),
axis('tight')
legend('signal norm','signal filter1', 'Peack1','signal filter2', 'Peack2','signal 3','Peack3')
xlabel('time in min')
ylabel('signal')
title('Peack detection of a PPG')

figure,
plot(ind_R1(2:end), pulse1)
hold all
plot(ind_R2(2:end),pulse2)
plot(ind_R3(2:end),pulse3)
legend('pulse1','pulse2','pulse3')