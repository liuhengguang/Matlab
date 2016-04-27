clear all
close all
clc

addpath(genpath('./functions'));
addpath(genpath('./signals'));
%% Signal and Data definitions

sample = load('Pierre_BVP.csv');
%signal = sample(:,2)';
signal = sample(3:end)';

Fs = 64; % sampling frequency
time = linspace(0,length(signal)/Fs, length(signal));

Tpulse = 6;

%% Wavelet Decomposition
lev = wmaxlev(signal,'db5');
[thr,sorh,keepapp] = ddencmp('den','wv',signal);
xd3 = wdencmp('gbl',signal,'db5',real(lev),thr,sorh,keepapp);

signal_wav = xd3;

%% Band-pass filter
Wn = 2*[0.5 3]/Fs;
[b2,a2] = cheby2(3,30,Wn,'bandpass');
signal_filt = filtfilt(b2,a2,signal_wav);

figure,
pwelch(signal,[],[],[],Fs)
figure,
pwelch(signal_filt,[],[],[],Fs)

%% Peak Detection
[ R, ind_R ] = detection_peack( signal_filt, Fs, time, 0, 0, 0.2);

figure, plot(time/60,signal_filt); 
hold all
plot(ind_R/60,R,'x')
grid on; axis('tight'), 
%% Heart Rate 
[ pulse ] = heart_rate(ind_R);
p = 50;
pulse1 = filter(ones(1,p)/p,1,pulse);

figure, plot(ind_R(p:end-1)/60/60,pulse1(p:end))
grid on; axis('tight')
xlabel('time (hour)')
ylabel('Amplitude')
title('Heart rate')
T =20;
[ pulse_smooth ] = heart_rate_smooth(ind_R, Fs, length(signal_filt), T);

timeTsec = 1:Fs*T:length(signal_filt);

figure, plot(timeTsec(1:end-1)/Fs/60/60,pulse_smooth)
grid on; axis('tight')
xlabel('time (hour)')
ylabel('Amplitude')
title('Heart rate smooth')
%% Respiratory Rate
[ respiratoryRate ] = respiratory_rate( signal, Fs );

%% Results
time_min = 1:Fs*60:length(signal);

figure, 
subplot(311)
plot(timeTsec(1:end-1)/Fs/60/60,pulse_smooth)
grid on; axis('tight')
xlabel('time (hour)')
ylabel('Amplitude')
title('Heart rate')
subplot(312)
plot(time_min(1:end-1)/Fs/60/60,respiratoryRate)
grid on
axis('tight')
xlabel('time (hour)')
ylabel('Amplitude')
title('Respiratory Rate')
subplot(313)
plot(time/60/60,signal)
axis('tight')
xlabel('time (hour)')
ylabel('Amplitude')
title('signal')

