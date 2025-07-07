function [Adaptive_weight, Filter_Order, Filter_step] = Adaptive_filter()
%ADAPTIVE_FILTER Summary of this function goes here
%   Detailed explanation goes here
    Filter_Order = 40;
    Filter_step = 0.001;
    % Adaptive_weight = dps.LMSFilter('Length', Filter_Order, 'StepSize',Filter_step);
    Adaptive_weight = zeros(1,Filter_Order);
end

