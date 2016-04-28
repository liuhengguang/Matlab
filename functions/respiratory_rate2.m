function [ respiratoryRate ] = respiratory_rate2( signal, Fs )
% This function calculate the respiratory rate of a ppg signal by
% calculating the envellop of the signal
% signal: PPG signal
% Fs: Sampling Frequency
% respiratoryRate: respiratory rate by min
time_min = 1:floor(Fs*60):length(signal);
time_min(end+1) = length(signal);
[yupper1,~] = envelope(signal,floor(Fs),'peak');

[~, I]=findpeaks(yupper1,Fs,'MinPeakDistance',1);

respiratoryRate = zeros(1,length(time_min)-1);

for k =1:length(time_min)-1
    for p= 1:length(I)
        if I(p)*Fs>=time_min(k) && I(p)*Fs<=time_min(k+1)
            respiratoryRate(k) = respiratoryRate(k)+1;
        end
    end
end

end

