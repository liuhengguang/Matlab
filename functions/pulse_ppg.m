function [ pulse ] = pulse_ppg( time_max, Ts, ind_R, Fs  )
% This function give the pulse by Ts of the ppg signal

% time_max: number of points which the signal is studied
% Ts: step of the pulse is calculated
% ind_R: index of the pic of the ppg
% Fs: sampling frequency
% pulse: pulse of the ppg signal

time = 1:floor(Fs*Ts):time_max;

pulse = zeros(1,length(time)-1);

for k = 1:length(time)-1
    for p = 1:length(ind_R)
        if ind_R(p)*Fs>time(k) && ind_R(p)*Fs<time(k+1)
            pulse(k) = pulse(k)+1;
        end
    end
end


end

