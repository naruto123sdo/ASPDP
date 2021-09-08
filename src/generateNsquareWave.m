% M - total length
% N - how many periods you have
function [x_sh, s] = generateNsquareWave(M, N)
s = zeros(1, M);
idices = 1 : M;
T0 = M / N;
idices = mod(idices, T0);
s(idices > ((1 / 4 ) * T0) & idices <= 3 / 4 * T0) = 1;
x_sh = 1 : M;
end