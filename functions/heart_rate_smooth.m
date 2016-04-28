function [ pulse_smooth ] = heart_rate_smooth(ind_R, Fs, N, T)
% This function give the heart rate by calculating the distance between two pulse
% and smoothing it every T
% ind_R: index of the peacks
% Fs: sampling frequency
% N: length of the signal
% T: time interval for smoothing
% pulse: heart_rate

timeTsec = 1:floor(Fs*T):N;
timeTsec(end+1)= N;
pulse = 60*(diff(ind_R)).^(-1);

for p = 1:2
    for k=2:length(pulse)-1
        if pulse(k)>pulse(k+1)*1.2
            if pulse(k)>pulse(k-1)*1.2
                pulse(k) = (pulse(k+1)+pulse(k-1))/2;
            end
        end
    end
end

for k = 1:length(timeTsec)-1
    buffer = [];
    for p = 1:length(ind_R)-1
        if timeTsec(k)<ind_R(p)*Fs && timeTsec(k+1)>ind_R(p)*Fs
            buffer = [buffer pulse(p)];
        end
    end
    pulse_smooth(k) = mean(buffer);
end

end

