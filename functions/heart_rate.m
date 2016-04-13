function [ pulse ] = heart_rate(ind_R)
% This function give the heart rate by calculating the distance between two pulse
% ind_R: index of the peacks
% pulse: heart_rate

pulse = 60*(diff(ind_R)).^(-1);

thresold = pulse<220;
pulse = pulse.*thresold;
for k = 1:length(pulse)
    if pulse(k) == 0
        if k == 1
           pulse(k)=pulse(k+1);
        else
            pulse(k)=pulse(k-1);
        end   
    end
end

end

