function [ respiratoryRate ] = respiratory_rate( signal, Fs )
% This function give the respiratory rate by min
% signal: data which is studied
% Fs: sampling frequency
% respiratoryRate: respiratory rate of the patient

Wn = 2*[0.1 0.4]/Fs;
[b1,a1] = butter(3,Wn,'bandpass');

signal_filt = filter(b1,a1,signal);
time = (0:length(signal)-1)/Fs;
%% 
time_20sec = 1:Fs*20:length(signal);
R = [];
I = [];

for k = 1:length(time_20sec)-1
    x = signal_filt(time_20sec(k):time_20sec(k+1));
    [~, Iinter]=findpeaks(x,Fs,'MinPeakDistance',1.5,'MinPeakHeight',1.5*mean(x));
    Iinter = Iinter+time(time_20sec(k));
    I = [I Iinter];
end

time_min = 1:Fs*60:length(signal);
respiratoryRate = zeros(1,length(time_min)-1);

for k =1:length(time_min)-1
    for p= 1:length(I)
        if I(p)*Fs>=time_min(k) && I(p)*Fs<=time_min(k+1)
            respiratoryRate(k) = respiratoryRate(k)+1;
        end
    end
end


end

