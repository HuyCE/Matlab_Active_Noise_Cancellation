function [Pulse_Response, Filter_Order] = Estimate_2nd_path(Secnd_pulse_response)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    % Init
    Filter_Order = 24;


    Pulse_Response = Secnd_pulse_response + Secnd_pulse_response*0.0001 ; % Add some noise to the true path
    Pulse_Response(Pulse_Response < 0.01*max(abs(Pulse_Response))) = 0; % Small values to zero for cleaner plot
    Pulse_Response = Pulse_Response / norm(Pulse_Response); % Normalize
    if length(Pulse_Response) < Filter_Order % lenght of secondary path estimation filter S^z
        Pulse_Response = [Pulse_Response, zeros(1, Filter_Order - length(Pulse_Response))];
    else
        Pulse_Response = Pulse_Response(1:Filter_Order);
    end
end