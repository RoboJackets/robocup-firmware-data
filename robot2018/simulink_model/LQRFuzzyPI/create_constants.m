X_0 = [0, 0, 0, 0];

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
w_n = 1/10;

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
C = eye(4,4);
D = zeros(4,4);

Q = [  eye(4,4)/100^2, zeros(4,4);
     zeros(4,4), eye(4,4)*100^2];
R = eye(4,4)*2;

s = ss(A, B, C, D);

[K, ~, e] = lqi(s, Q, R);

Q2 = eye(4,4);
R2 = eye(4,4)*2;
[K2, ~, e2] = lqr(s, Q2, R2);

BotToWheel = G' / r;
WheelToBot = pinv(BotToWheel);