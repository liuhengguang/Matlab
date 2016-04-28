%% Algorithm for finding the respiratory rate in a PPG signal 
clear all
close all

addpath(genpath('../functions'));
addpath(genpath('../signals'));

%% Signal and data definition

load('Gauthier_25_04_PPG.mat')
signal = Gauthier_25_04_PPG';
Fs = floor(100.51); % sampling frequency
time = (0:length(signal)-1)/Fs;


figure, plot(time/60,signal)
axis('tight')
xlabel('time (min)')
ylabel('Amplitude')
title('signal')

%% Envelope of the signal detection
[yupper1,ylower1] = envelope(signal,floor(Fs),'peak');

figure, plot(time/60,signal)
hold on 
plot(time/60,yupper1)
plot(time/60,ylower1)
legend('signal','yupper','ylower')
axis('tight')
xlabel('time (min)')
ylabel('Amplitude')
title('signal')

figure,
plot(time/60,yupper1)
axis('tight')
xlabel('time (min)')
ylabel('Amplitude')
title('Enveloppe')

%% Peaks detection
[R, I]=findpeaks(yupper1,Fs,'MinPeakDistance',1);

time_min = 1:Fs*60:length(signal);
respiratory_rate = zeros(1,length(time_min)-1);

for k =1:length(time_min)-1
    for p= 1:length(I)
        if I(p)*Fs>=time_min(k) && I(p)*Fs<=time_min(k+1)
            respiratory_rate(k) = respiratory_rate(k)+1;
        end
    end
end

%% Results
figure, plot(time_min(1:end-1)/Fs/60,respiratory_rate)
grid on
axis('tight')
xlabel('time (min)')
ylabel('Amplitude')
title('Respiratory Rate')