% Signal Generator
function [noise, N, t] = Noise_generator()
    fs = 1000; % sampling rate
    T = 240; % Duration
    t = 0:1/fs:T-1/fs; % Time vector
    N = T*fs; % Number of samples

    % Frequencies element
    f1 = 90;
    f2 = 70;
    f3 = 120;

    % Amplitudes
    A1 = 0.6;
    A2 = 0.2;
    A3 = 0.5;

    % signal generator
    noise = A1*sin(2*pi*f1*t) + A2*sin(2*pi*f2*t) + A3*sin(2*pi*f3*t);
end

    