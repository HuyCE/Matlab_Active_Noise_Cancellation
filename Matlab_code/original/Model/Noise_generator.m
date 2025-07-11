% Signal Generator
function [noise, N, t] = Noise_generator()
    fs = 1000; % sampling rate
    T = 20; % Duration
    t = 0:1/fs:T-1/fs; % Time vector
    N = T*fs; % Number of samples

    % Frequencies element
    f1 = 50;
    f2 = 70;
    f3 = 120;

    % Amplitudes
    A1 = 0.5;
    A2 = 1;
    A3 = 1.6;

    % signal generator
    noise = A1*sin(2*pi*f1*t) + A2*sin(2*pi*f2*t) + A3*sin(2*pi*f3*t);

    % Un-comment this if use noise sample
    % [noise,fs] = audioread("noise_sample.wav");
    % Fs = 1000;
    % new_noise = resample(noise, Fs, fs);
    % noise = new_noise';
    % fs = Fs;
    % t = 20;
    % N = t*fs;
    % noise = noise(1:N);
end

    
