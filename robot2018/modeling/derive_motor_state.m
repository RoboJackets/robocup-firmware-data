
syms theta0 theta1 theta2 theta3
syms L R r g I_asm
syms phi
syms M_bot
syms I_bot
syms K_e K_t K_f


G = [-sin(theta0), -sin(theta1), -sin(theta2), -sin(theta3);
      cos(theta0),  cos(theta1),  cos(theta2),  cos(theta3);
              1/L,          1/L,          1/L,          1/L];

J = [M_bot,     0,     0;
         0, M_bot,     0;
         0,     0, I_bot];

gbR = [cos(phi), -sin(phi), 0;
       sin(phi),  cos(phi), 0;
              0,         0, 1];

M = (1 / (g*r))*inv(J)*gbR*G;
disp('M');
simplify(M)
N = M*I_asm + gbR*g*r;
disp('N');
simplify(N)

A = -pinv(N)*((M*K_e*K_t/R) + M*K_f + diff(bgR, 'phi')*g*r);
B = pinv(N)*M*K_t / R;

disp('A');
simplify(A)
disp('B')
simplify(B)