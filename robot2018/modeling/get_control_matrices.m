
function [ A, B ] = get_control_matrices(params, phi_val)

    phi_sym = sym('phi');

    thetas = params.thetas;
    L = params.L;
    J_L = params.J_L;
    J_m = params.J_m;
    n = params.n;
    r = params.r;
    m = params.m;
    c_m = params.c_m;
    c_L = params.c_L;
    k_m = params.k_m;
    Rt = params.Rt;
    EM = params.EM;


    G = [-sin(thetas(1)), -sin(thetas(2)), -sin(thetas(3)), -sin(thetas(4));
          cos(thetas(1)),  cos(thetas(2)),  cos(thetas(3)),  cos(thetas(4));
                    L,            L,            L,           L];

    gbR = [cos(phi_sym), -sin(phi_sym), 0;
           sin(phi_sym),  cos(phi_sym), 0;
                      0,             0, 1];


    Z = (J_m + J_L/(n^2))*eye(4) + ((r^2)/(n^2))*pinv(G)*gbR.'*m*gbR*pinv(G.');
    V = (c_m + (c_L/(n^2)))*eye(4) + ((r^2)/(n^2))*pinv(G)*gbR.'*m*diff(gbR, phi_sym)*pinv(G.');

    % E = G*w_m_dot + H*w_m

    G = (Rt/k_m)*Z;
    H = (Rt/k_m)*V + EM*eye(4);

    A_sym = -pinv(G)*H;
    B_sym = pinv(G);
    % phi = phi_val;
    % double(subs(A_sym))
    % double(subs(B_sym))

    x = [0, 0, 0, 0].';
    u = [1, 2, 1, 1].';
    A = double(subs(A_sym, phi_sym, phi_val));
    B = double(subs(B_sym, phi_sym, phi_val));
end

% x_hist = x.';
% dt = 1/60;
% for t=0:dt:1
%     x = x + (A_d*x + B_d*u) * dt;
%     x_hist = [x_hist; x.'];
% end
% 
% 
% for i=1:4
%     hold on;
%     plot(x_hist(:,i));
% end