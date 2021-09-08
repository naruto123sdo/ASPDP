function sigma_hat_map = findSigmaMap2ndComp(I, M, cutoff)
% get the size of I
[h, w, total_steps] = size(I);

% total steps excluding black and white
total_steps = total_steps - 2;

% Normalization
I_norm = (I - I(:, :, end)) ./ (I(:, :, end - 1) - I(:, :, end));

% cutoff
I_norm(1 : cutoff(1), :, :) = nan;
I_norm(end - cutoff(2) : end, :, :) = nan;
I_norm(:, end - cutoff(3) : end, :) = nan;
I_norm(:, 1 : cutoff(4), :) = nan;

% original square wave
[~, s] = generateNsquareWave(total_steps, M);
% figure, plot(s); title('s');
S = fft(s);

% Fourier window
fs = 1;
f = 0:total_steps - 1;
f = f * (fs / total_steps);

% using the 2nd component
G_x = f(M + 1);

fft_cube = fft(I_norm(:, :, 1 : total_steps), total_steps, 3);
G_y_map = abs(reshape(fft_cube(:, :, M + 1), [h w])) / abs(S(M + 1));
sigma_hat_map = sqrt( - 2 * log(G_y_map) / (2 * pi * G_x) ^ 2);
sigma_hat_map(imag(sigma_hat_map) ~= 0) = nan;

end