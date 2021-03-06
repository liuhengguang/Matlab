function [ pulse ] = heart_rate(ind_R)
% This function give the heart rate by calculating the distance between two pulse
% ind_R: index of the peacks
% pulse: heart_rate

pulse = 60*(diff(ind_R)).^(-1);


for p = 1:2
    for k=2:length(pulse)-1
        if pulse(k)>pulse(k+1)*1.3
            if pulse(k)>pulse(k-1)*1.3
                pulse(k) = (pulse(k+1)+pulse(k-1))/2;
            end
        end
    end
end

end

