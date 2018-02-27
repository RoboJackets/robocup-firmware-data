addpath('../modeling/');

params = struct;
params.thetas = [30, 180 - 30, 180 + 39, 360 - 39]*pi/180.0;
params.L = 0.0824;
params.J_L = 2.158e-5;
params.J_m = 1.35e-5;
params.J = 0.013;
params.n = 4.091;
params.r = 0.0285;
params.m = 3.678;
params.c_m = .0015;
params.c_L = 0;
params.k_m = 0.035;
params.Rt = 0.978;
params.EM = 1/285;

[A, B] = get_control_matrices(params, 0);

vars = read_excitation('excite_1');
%plot_excitation('excite_1');

x = [0, 0, 0, 0].'; % assume we start with no vel
x_hist = x.';

for i=1:length(vars)
% Calculate update to state variables
    row = vars(i,:);
    input = row(5:8);
    
    x = x + (A*x + B*input.') * (1/60);
    x_hist = [x_hist; x.'];
end

subplot(3,1,1);
for i=1:4
    hold on;
    plot(x_hist(:,i));
end

subplot(3,1,2);
title('Encoder measurements (rad/s)');
hold on;
for i=1:4
    plot(vars(:,i));
end
legend('W1', 'W2', 'W3', 'W4');

subplot(3,1,3);
title('W1 model vs W1 real');
hold on;
plot(vars(:,1));
plot(x_hist(:,1));
legend('W1 Act', 'W1 Model');

