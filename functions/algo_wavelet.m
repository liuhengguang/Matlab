function [ind_R1, pulse_T1, pulse1, ind_R2, pulse_T2, pulse2, ind_R3, pulse_T3, pulse3 ] = algo_wavelet( signal, Fs, Tpulse )
% This function calculate the heart rate by using a wavelet decomposition
% signal: signal which is studied
% Fs: sampling Frequency 
% Tpulse: step of the pulse is calculated
% ind_R1: index of the first wavelet decomposition peacks
% pulse_min1: number of the first wavelet decomposition peacks by a Tpulse
% pulse1: heart rate whith first wavelet decomposition filter
% ind_R2: index of the second wavelet decomposition peacks
% pulse_min2: number of the second wavelet decomposition peacks by a Tpulse
% pulse2: heart rate whith first second decomposition filter

%% Data definition
time = (0:length(signal)-1)/Fs;

%% Wavelet Decomposition
% using the matlab function wden
lev = 5;
 
% decomposition. 
[c,l] = wavedec(signal,lev,'db5');
 
% threshold the decomposition structure [c,l].
xd1 = wden(c,l,'sqtwolog','s','sln',lev,'db5');

% 'mln' for rescaling done using level-dependent estimation of level noise
xd2 = wden(signal,'modwtsqtwolog','s','mln',lev,'sym8');

% using den and wdencmp
[thr,sorh,keepapp] = ddencmp('den','wv',signal_noise);
xd3 = wdencmp('gbl',signal_noise,'db3',4,thr,sorh,keepapp);
%% Derivating the signal

windowSize = 15;
b1 = (1/windowSize)*ones(1,windowSize);
a1 = 1;

x = xd1;
b2 = [2,1,0,-1,-2];
a2 = 1;
filter_size = length(b2);

signal_filt1 = filtfilt(b1,a1,x);
signal_filter1 = filter(b2,a2,signal_filt1);

x = xd2';
signal_filt2 = filtfilt(b1,a1,x);
signal_filter2 = filter(b2,a2,signal_filt2);

x = xd3;
signal_filt3 = filtfilt(b1,a1,x);
signal_filter3 = filter(b2,a2,signal_filt3);
%% Peack Detection
[ R1, ind_R1 ] = detection_peack( signal_filter1, Fs, time, 0, 0.68, 0.2);
[ R2, ind_R2 ] = detection_peack( signal_filter2, Fs, time, 0, 0.68, 0.2);
[ R3, ind_R3 ] = detection_peack( signal_filter3, Fs, time, 0, 0.68, 0.2);

%% Pulse Obtention
[ pulse_T1 ] = pulse_ppg( length(signal), Tpulse ,ind_R1, Fs);
[ pulse_T2 ] = pulse_ppg( length(signal), Tpulse ,ind_R2, Fs);
[ pulse_T3 ] = pulse_ppg( length(signal), Tpulse ,ind_R3, Fs);

[ pulse1 ] = heart_rate(ind_R1);
[ pulse2] = heart_rate(ind_R2);
[ pulse3] = heart_rate(ind_R3);

figure,
plot(time/60,signal-mean(signal))
hold on
plot(time/60,signal_filter1)
plot(ind_R1/60, R1,'x','linewidth',2),
plot(time/60,signal_filter2)
plot(ind_R2/60, R2,'x','linewidth',2),
plot(time/60,signal_filter3)
plot(ind_R3/60, R3,'x','linewidth',2),
axis('tight'),
legend('signal norm','signal filter1', 'Peack1','signal filter2','Peack2','signal filter3','Peack3)
xlabel('time in min')
ylabel('signal')
title('Peack detection of a PPG')
end

