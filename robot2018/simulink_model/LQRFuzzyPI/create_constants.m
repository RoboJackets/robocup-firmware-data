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

wvR = pinv(G.')*r;

% Q/R for the integral state space
Q = [  eye(4,4)/100^2, zeros(4,4);
     zeros(4,4), eye(4,4)*100^2];
R = eye(4,4)*2;

s = ss(A, B, C, D);

[K, ~, e] = lqi(s, Q, R);

% Q/R for just simple state feedback (-Kx)
Q2 = eye(4,4);
R2 = eye(4,4)*2;
[K2, ~, e2] = lqr(s, Q2, R2);

BotToWheel = G' / r;
WheelToBot = pinv(BotToWheel);

% Camera delay and our "delay" constant for the smith predictor
delay = 100;
delay_est = delay * 1;

% PID Constants
% Translational (t) / Rotation (w)
tp = 0;
ti = 0;
td = 0;
wp = 0;
wi = 0;
wd = 0;

%%%% Descrete model constants %%%%

% Camera
delay_sample = 0;
camera_noise = 0.000001;
camera_ts = 0.01;

% Radio
buffer_size = 1;
encoder_ts = 0.01;

% Check this
K2 = K(1:4, 5:8);
K1 = K(1:4, 1:4);

% See word doc for this
Ao = [zeros(3,3), gbR*pinv(G')*r/n, zeros(3,4), zeros(3,4);
      zeros(4,3),           A-B*K1,      -B*K2,      -B*K1;
      zeros(4,3),                C, zeros(4,4), zeros(4,4);
      zeros(4,3),       zeros(4,4), zeros(4,4),      A-L*C];
Ao = double(subs(Ao, phi_sym, 0));

E2 = eye(3,3);
E1 = eye(4,4);

Bo = [        E2, zeros(3,4), zeros(3,4), zeros(3,4);
      zeros(4,3), zeros(4,4),         E1, zeros(4,4);
      zeros(4,3),  -eye(4,4), zeros(4,4),   eye(4,4);
      zeros(4,3), zeros(4,4),        -E1, eye(4,4)*L];

Co = [  eye(3,3), zeros(3,4), zeros(3,4), zeros(3,4);
      zeros(4,3),          C, zeros(4,4), zeros(4,4)];
  
Do = [1, 0, 0, 0;
      0, 0, 0, 0];
Do = zeros(7,15);
  

ssi = ss(Ao(4:end, 4:end), Bo(4:end, 4:end), Co(4:end, 4:end), Do(4:end, 4:end));
sso = ss(Ao, Bo, Co, Do);
ssod = c2d(sso, encoder_ts);

% Kalman filter
F_k = ssod.A; % A
B_k = ssod.B; % B
H_k = ssod.C; % C
Q_k = eye(15, 15); % Covariance of process noise
R_k = [eye(3, 3)*1000, zeros(3, 4);
       zeros(4,3), eye(4, 4)*0.001]; % Variance of observation noise


