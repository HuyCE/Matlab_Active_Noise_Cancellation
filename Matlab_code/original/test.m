close all; clear all; clc;

% Signal characteristics
fs = 1000;             % Tần số lấy mẫu (Hz)
T = 30;                 % Thời gian tín hiệu (giây)
t = 0:1/fs:T-1/fs;     % Vector thời gian
N = T * fs;

% Frequencies element
f1 = 50;
f2 = 120;
f3 = 300;

% Amplitudes (tuỳ chọn)
A1 = 1;
A2 = 0.5;
A3 = 0.8;

% Tạo sóng sin đa tần số
signal = A1*sin(2*pi*f1*t) + A2*sin(2*pi*f2*t) + A3*sin(2*pi*f3*t);

%% Setup

% Primary path
p_delay = 5; % sample



%%
L = 64;
W = zeros(1,L);



% define buffer
x_buffer = zeros(1,L);
e = zeros(1,N);
debug_norm_W = zeros(1,N);

for n = 1:N
    x_buffer = [signal(n), x_buffer(1:end-1)];

    y = dot(W, x_buffer);
    e(n) = signal(n) - y;
    
    debug_norm_W(n) = norm(W);
    W = W + (0.0001 * x_buffer * e(n));


end

figure;

subplot(2,1,1)
plot(t,e)

subplot(2,1,2)
plot(t,debug_norm_W)