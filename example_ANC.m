function [e, y, w] = example_ANC(x, d, s_hat, mu, N)
% fxLMS_ANC: Perform FxLMS-based Active Noise Control
%
% Inputs:
%   x     - Reference input signal (e.g., noise source)
%   d     - Desired signal (measured at error mic, includes primary noise)
%   s_hat - Estimated secondary path impulse response (column vector)
%   mu    - Step size (learning rate)
%   N     - Filter order (number of taps)
%
% Outputs:
%   e     - Error signal after ANC
%   y     - Output (anti-noise) signal
%   w     - Final adaptive filter coefficients

% Initialize
len = length(x);
x = x(:);         % ensure column vector
d = d(:);
s_hat = s_hat(:);
w = zeros(N, 1);  % adaptive filter
y = zeros(len, 1);
e = zeros(len, 1);
x_buf = zeros(N, 1);
x_filt = zeros(length(s_hat) + N - 1, 1);  % for filtered-x

% Precompute filtered reference signal (x filtered through s_hat)
x_hat = filter(s_hat, 1, x);

% Main FxLMS loop
for n = 1:len
    % Update input buffer
    x_buf = [x(n); x_buf(1:N-1)];

    % Filtered-x input for adaptation
    if n >= N
        x_hat_vec = x_hat(n:-1:n-N+1);
    else
        x_hat_vec = [x_hat(n:-1:1); zeros(N - n, 1)];
    end

    % Generate output (anti-noise)
    y(n) = w' * x_buf;

    % Error signal = desired - output (assuming real secondary path ≈ s_hat)
    e(n) = d(n) - y(n);

    % Weight update (FxLMS)
    w = w + mu * e(n) * x_hat_vec;
end

end
