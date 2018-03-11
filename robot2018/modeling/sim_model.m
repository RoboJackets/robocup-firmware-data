%% Derive Model Based on System Parameters
% Model-based PI–fuzzy control of four-wheeled omni-directional mobile robots
% https://www.sciencedirect.com/science/article/pii/S0921889011001230

addpath('../plant_excitation');

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
Ts = 1/60;
dsys = c2d(sys, Ts);
% dsys = c2d(sys, 0.005);

%% Compare Discretized System Model to Actual Response
% 
% [t, Ts, input_v, wheel_vels] = read_excitation('excite_1');
% 
% sim_wheel_vels = lsim(dsys, input_v, t);
% 
% num_wheels = 4;
% for n=1:num_wheels
%     subplot(num_wheels,1,n);
%     title(['W' num2str(n) ': Real vs Sim (rad/sec)']);
%     hold on;
%     plot(wheel_vels(:,n));
%     plot(sim_wheel_vels(:,n));
%     legend('Real', 'Sim');
% end

%% Continuous Time LQR Step Response Graph


Q = 1*eye(4);
R = 2*eye(4);

K = lqr(sys.A,sys.B,Q,R);

Ac = [(sys.A-sys.B*K)];
Bc = [sys.B];
Cc = [sys.C];
Dc = [sys.D];

sys_cl = ss(Ac,Bc,Cc,Dc);

t = 0:0.0001:1/100;
r = 2*ones(length(t),4);
lsim(sys_cl,r,t);
%[AX,H1,H2] = plotyy(t,y(:,1),t,y(:,2),'plot');
%title('Step Response with LQR Control')


%% Get System Step Response of LQR Controlled Value
Q = 2*eye(4);
R = eye(4);

Ts_c = 1/200;
% dsys_c = ss(sys.A, sys.B, sys.C, sys.D, Ts_c);
dsys_c = c2d(sys, Ts_c);

[K, S, e] = dlqr(dsys_c.A, dsys_c.B, Q, R);

for i = 1:4
    for j = 1:4
        fprintf('%f', K(i,j))
        
        if (~(j == 4 && i == 4))
            fprintf(', ');
        end
    end
    
    if (i ~= 4)
        fprintf('\n');
    end
end
fprintf(';\n');

sys_cl = ss(Ac, Bc, Cc, Dc, Ts_c);

t = 0:Ts_c:1;
r = ones([length(t) 4]);

r(:,2:4) = 0*r(:,2:4);

xs = [0 0 0 0];
for i=2:100
    xs(i,:) = dsys_c.A*xs(i-1,:)' + dsys_c.B*K*[1 -.8 .8 -1]';
end

for i=1:4
    hold on;
    subplot(4,1,i);
    plot(xs(:,i));
end

% r(:,2) = -r(:,2);
% [y,t,x]=lsim(sys_cl,r,t);
% for n=1:4
%     subplot(4,1,n);
%     plot(t, y(:,n));
% end
%[AX,H1,H2] = plotyy(t,y(:,1),t,y(:,2),'plot');