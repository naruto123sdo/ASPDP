close all
clear all

%% user input
% 24 steps phase shifting + 1 white + 1 black for normalization
steps = 26; 
cutoff = [0 0 0 0];

% res
h = 1140;
w = 912;

% pattern repeated for M times
M = 3; 
texture_threshold = 30;

%% read in data
% simulation data
load('../data/simulation_holes_depth_minus1_2ndComp_even.mat');

% check the data by ploting the white image 
texture = I(:, :, end - 1);
figure, imshow(uint8(texture));

% adding noise
a = - 127.5;
b = 127.5;
for i = 1 : (steps - 2) * M
    temp = reshape(I(:, :, i), [h w]);
    temp = temp + floor(0.01 * ((b - a) * rand(h, w) + a));
    I(:, :, i) = temp;
end
figure, imshow(uint8(I(:, :, 1)));

%% find sigma and z
% calibration data
k = [8.4531 -2.3870 0.9972 0.1930];
A0 = k(1); A1 = k(2); B0 = k(3); B1 = k(4);

sigma_hat = findSigmaMap2ndComp(I, M, cutoff);
z_map = (A0 + A1 .* sigma_hat) ./ (B0 + B1 .* sigma_hat);

%% x y estimation
x = 0:14/(h-1):14;
y = 0:10/(w-1):10;

[Y, X] = meshgrid(y, x);
a = z_map;
mask = ones(h,w);
mask(texture < texture_threshold) = nan;
a(isnan(mask)) = nan;

a = mask .* z_map ;
%% 3D visualization
scale = 1000;
figure,
a(a <= - 5) = nan;
surf(X*scale, Y*scale, a*scale,'FaceColor', 'interp',...
        'EdgeColor', 'none',...
        'FaceLighting', 'gouraud');
camlight right
camlight right

axis equal;
axis off
caxis([-6 -1] * scale);
view(109, 51);
c = colorbar;
c.FontSize = 20;
title(c, 'Z(\mum)');

%% plot cross-sections
% construct the ground truth cross section
cros_x = X(:, 1) * scale;
cros_y_sim = a(:, w / 2) * scale;
cros_y_true = cros_y_sim;
cros_y_true(cros_y_true > - 1050 & cros_y_true < - 950) = - 1000;
cros_y_true(cros_y_true > - 2050 & cros_y_true < - 1950) = - 2000;
cros_y_true(cros_y_true > - 3050 & cros_y_true < - 2950) = - 3000;
cros_y_true(cros_y_true > - 4050 & cros_y_true < - 3950) = - 4000;

figure, plot(cros_x, cros_y_sim, 'LineWidth', 2.5);
hold on;
plot(cros_x, cros_y_true, '--', 'LineWidth', 2.5);

legend({'Simulation', 'Ground Truth'}, 'location', 'north', 'FontSize', 40);
xlabel('X(\mum)', 'FontSize', 40);
ylabel('Z(\mum)', 'FontSize', 40);
set(gca,'FontSize',40)

