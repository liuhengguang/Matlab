clear all
close all
clc

addpath(genpath('../functions'));
addpath(genpath('../signals'));
%% Data an signals definition

load('Accel_X.mat')
load('Accel_Y.mat')
load('Accel_Z.mat')
load('PPG_A13.mat')
load('Timestamp.mat')

Time = (Timestamp-Timestamp(1))*10^(-3);
Fs = 128; % sampling frequencies
N = length(PPG_A13);
nyquistFreq = Fs/2;
NFFT = 2^nextpow2(N);

figure,
subplot(211)
plot(Time,PPG_A13)
axis('tight')
grid on
xlabel('time (sec)')
ylabel('Amplitude')
title('signal')
subplot(212)
plot(Time,Accel_X)
hold all
plot(Time,Accel_Y)
plot(Time,Accel_Z)
axis('tight')
grid on
legend('acc X', 'acc Y', 'acc Z')
xlabel('time (sec)')
ylabel('Amplitude')
title('Accelerometre')

%% Look to a correlation of the signal
Xmean = mean(diff(Accel_X));
Ymean = mean(diff(Accel_Y));
Zmean = mean(diff(Accel_Z));

T = 5;
[M, I] = max([Xmean Ymean Zmean]);
maxCorr = 0;
acc = [Accel_X Accel_Y Accel_Z];
accel = acc(:,I);
timeTsec = 1:Fs*T:length(PPG_A13);
timeTsec(end) = length(PPG_A13);
Xout = [];
order = T;
l = order+1; % filter length
lambda = 1; % RLS forgetting factor
invcov = T*eye(l);
RLSfilt = adaptfilt.rls(l, lambda, invcov);
for k=1:length(timeTsec)-1
    if k == length(timeTsec)-1
        accelShort = accel(timeTsec(k):timeTsec(k+1));
        x = PPG_A13(timeTsec(k):timeTsec(k+1));
    else
        accelShort = accel(timeTsec(k):timeTsec(k+1)-1);
        x = PPG_A13(timeTsec(k):timeTsec(k+1)-1);
    end
    [corrM, lagsShort] = xcorr(accelShort,x, 'coeff');
    corrM = corrM((length(accelShort)):end);
    lagsShort = lagsShort((length(accelShort)):end);
    [corr, i] = max(corrM);
    
    if corr>0.9
        % get the RLS filter
        [outRLSshort, errorRLS] = filter(RLSfilt, accelShort, x);
        Xout = [Xout; outRLSshort];
    else
        Xout = [Xout; x];
    end
end

figure,
subplot(211)
plot(Time,PPG_A13)
axis('tight')
grid on
xlabel('time (sec)')
ylabel('Amplitude')
title('Signal')
subplot(212)
plot(Time,Xout)
axis('tight')
grid on
xlabel('time (sec)')
ylabel('Amplitude')
title('Decoralated Signal')

%% Band-pass filter and pulse obtention
Wn = 2*[0.5 3]/Fs;
[b2,a2] = cheby2(3,30,Wn,'bandpass');
signal_filt = filtfilt(b2,a2,Xout);

[ R, ind_R ] = detection_peack( signal_filt, Fs, Time, 0, 0, 0.2);
[ pulse ] = heart_rate(ind_R);

%% Results
figure, plot(Time, signal_filt)
hold all
plot(ind_R,R,'x')
axis('tight')
grid on
legend('filter signal', 'Peaks')
xlabel('time (sec)')
ylabel('Amplitude')
title('Detection PPG')

figure, plot(ind_R(2:end),pulse)
axis('tight')
grid on
xlabel('time (sec)')
ylabel('Amplitude')
title('Heart rate')