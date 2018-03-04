%% Derive Model Based on System Parameters
% Model-based PI–fuzzy control of four-wheeled omni-directional mobile robots
% https://www.sciencedirect.com/science/article/pii/S0921889011001230

thetas = [30, 180 - 30, 180 + 39, 360 - 39]*pi/180.0;
L = 0.0824;
J_L = 2.158e-5;
J_m = 1.35e-5;
J = 0.013;
n = 4.091;
r = 0.0285;
m = 3.678;
c_m = .0001;
c_L = 0.007;
k_m = 0.035;
Rt = 0.978;

% Rad/S = RPM * ??
% RPM = (1 (rev) / 1 (min)) * (2*pi (rad) / 1 (rev)) * (1 (min) / 60 (sec)
rpm_to_rad_p_sec = 2*pi / 60;
EM = 1/(285 * rpm_to_rad_p_sec); % V/RPM, converted to SI units

G = [-sin(thetas(1)), -sin(thetas(2)), -sin(thetas(3)), -sin(thetas(4));
    cos(thetas(1)),  cos(thetas(2)),  cos(thetas(3)),  cos(thetas(4));
    L,            L,            L,           L];

phi_sym = sym('phi');

gbR = [cos(phi_sym), -sin(phi_sym), 0;
    sin(phi_sym),  cos(phi_sym), 0;
    0,             0, 1];

M = [m, 0, 0;
    0, m, 0;
    0, 0, J];

Z = (J_m + J_L/(n^2))*eye(4) + ((r^2)/(n^2))*pinv(G)*gbR.'*M*gbR*pinv(G.');
V = (c_m + (c_L/(n^2)))*eye(4) + ((r^2)/(n^2))*pinv(G)*gbR.'*M*diff(gbR, phi_sym)*pinv(G.');

S = (Rt/k_m)*Z;
T = (Rt/k_m)*V + EM*eye(4);

A_sym = -pinv(S)*T;
B_sym = pinv(S);

% After taking derivative of gbR, phi_sym becomes phi_sym_dot, which we
% substitute in 0 for because we linearize around 0 rotation velocity.
A = double(subs(A_sym, phi_sym, 0));
B = double(subs(B_sym, phi_sym, 0));

sys = ss(A, B, eye(4), 0);

% Convert to discrete system
% Our data samples are taken 1/60th apart, but control is really running
% at 200Hz+. Do we do the discretization twice, one for sample data and
% one for actual control on the bots?
dsys_vis = c2d(sys, 1/60);
dsys = c2d(sys, 0.005);

%% Calculate Optimal Gains Matrix

% Calculate Optimal Gains Matrix
Q = 2*eye(4);
R = eye(4);
[K, S, e] = lqrd(dsys.A, dsys.B, Q, R, dsys.Ts);

%% Compare Discretized System Model to Actual Response

[input_v, wheel_vels] = read_excitation('excite_1');

sim_wheel_vels = zeros(length(input_v), 4);
sim_wheel_vels(1,:) = [0, 0, 0, 0]; % 0 velocity initial assumption

for i=2:length(input_v)
% Calculate update to state variables
    input = input_v(i,:);
    x = sim_wheel_vels(i-1,:)';
    
    x = dsys_vis.A*x + dsys_vis.B*input.';
    sim_wheel_vels(i,:) = x';
end

% subplot(3,1,1);
title('W1 model vs W1 real (rad/s)');
hold on;
plot(wheel_vels(:,1));
plot(sim_wheel_vels(:,1));
legend('W1 Act', 'W1 Model');

% We now have wheel velocities that are simulated, compare those the the
% actual ones sensed through encoders.

% subplot(3,1,2);
% for i=1:4
%     hold on;
%     plot(sim_wheel_vels(:,i));
% end

% subplot(3,1,3);
% title('Encoder measurements (rad/s)');
% hold on;
% for i=1:4
%     plot(wheel_vels(:,i));
% end
% legend('W1', 'W2', 'W3', 'W4');

