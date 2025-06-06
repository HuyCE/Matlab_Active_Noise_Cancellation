% Sample parameters
fs = 8000;                    % Sampling rate
t = 0:1/fs:1;                 % 1 second
x = sin(2*pi*300*t)';         % Reference: 300 Hz noise
d = filter([1 0.5], 1, x);    % Simulate primary path
s_hat = [0.1 0.05 0.01]';     % Estimated secondary path

% Call FxLMS function
mu = 0.01;
N = 64;
[e, y, w] = example_ANC(x, d, s_hat, mu, N);

% Plot results
subplot(2,1,1);
plot(d); title('Original Noise at Error Mic (d)');
subplot(2,1,2);
plot(e); title('Error Signal after ANC (e)');
