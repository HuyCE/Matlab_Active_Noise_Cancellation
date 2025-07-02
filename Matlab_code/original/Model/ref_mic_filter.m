function [Pulse_Response, Filter_Order] = ref_mic_filter()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    % Init
    Filter_Order = 32;
    filter_low_pass = 20; % lowest freq
    filter_high_pass = 200; % highest freq
    filter_sample_rate = 1000; % Hz

    
    Pulse_Response = fir1(Filter_Order, [filter_low_pass/filter_sample_rate/2 filter_high_pass/filter_sample_rate/2], "bandpass");
    Pulse_Response = Pulse_Response / norm(Pulse_Response);
    filter_delay = 1; % filter delay 15 sample
    Pulse_Response = [zeros(1,filter_delay) Pulse_Response];
    Filter_Order = length(Pulse_Response);
end