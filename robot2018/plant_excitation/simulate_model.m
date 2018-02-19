addpath('../modeling/');

p = RobotParams;

robot_params = RobotParams;

robot_params.M_bot = 2.205;
robot_params.I_bot = 0.00745879949;
robot_params.g = 1.0/3.0;
robot_params.r = 0.0285623;
robot_params.L = 0.0798576;
robot_params.Rt = 0.464;
robot_params.K_e = 30.0/(380*pi);
robot_params.K_t = 0.0251;
robot_params.K_f = 0.0001;
robot_params.I_asm = 2.43695253e-5;
robot_params.V = 18;
robot_params.wheel_angles = [30, 180 - 30, 180 + 39, 360 - 39]*pi/180.0;

J = robot_params.J;
G = robot_params.G;
B = robot_params.B;
A_1 = robot_params.A_1;
A_2 = robot_params.A_2;

vars = read_excitation('excite_1');

X_b_dot = [0, 0, 0, 0]; % assume we start with no vel

for i=1:length(vars)
% Calculate update to state variables
    dPhiDt = 0;
    X_b_dot_dot = A_1*X_b_dot + A_2*X_b_dot*dPhiDt + B*u;

end



