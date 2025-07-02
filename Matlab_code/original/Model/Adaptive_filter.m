function [Adaptive_weight, Filter_Order, Filter_step] = Adaptive_filter()
%ADAPTIVE_FILTER Summary of this function goes here
%   Detailed explanation goes here
    Filter_Order = 70;
    Adaptive_weight = zeros(1, Filter_Order);
    Filter_step = 0.00001;
end

