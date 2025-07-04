% Signal Generator
function [noise, N, t] = Noise_generator()
    fs = 1000; % sampling rate
    T = 12; % Duration
    t = 0:1/fs:T-1/fs; % Time vector
    N = T*fs; % Number of samples

    % Frequencies element
    f1 = 50;
    f2 = 70;
    f3 = 120;

    % Amplitudes
    A1 = 0.5;
    A2 = 1;
    A3 = 0;

    % signal generator
    noise = A1*sin(2*pi*f1*t) + A2*sin(2*pi*f2*t) + A3*sin(2*pi*f3*t);
end

    