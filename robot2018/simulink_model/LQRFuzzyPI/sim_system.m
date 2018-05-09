% Simulates the entire robot, from camera / encoder Kalman filter to robot
% dynamics

%% Time Grid
t_continous_period = 0.0001;
t_robot_period     = 1 / 200.0;
t_camera_period    = 1 / 60.0;

t_max = 10;

time = 0:t_continous_period:t_max;

%% Prealloc
% Robot wheel speed controller
% Note: Caps represent output to graph variables
%       Lowercase means it contains the current iterations
robot_X_plant = zeros( 4, length(time) ); % Real wheel vels
robot_X_hat   = zeros( 4, length(time) ); % Current estimated wheel vels
robot_U       = zeros( 4, length(time) ); % Input voltage
robot_Y       = zeros( 4, length(time) ); % Same as x
robot_SIGMA   = zeros( 4, length(time) ); % Error integrator
robot_BDY_VEL = zeros( 3, length(time) ); % Body Velocities

% Position controller
full_X_hat   = zeros( 15, length(time) ); % Estimated state vector
full_U       = zeros( 3, length(time) );  % Input velocity target
camera_Y     = zeros( 3, length(time) );  % Camera output
encoder_Y    = zeros( 4, length(time) );  % Encoder output

%% Initial Conditions
robot_x_plant = zeros( 4, 1 );
robot_x_hat   = zeros( 4, 1 );
robot_u       = zeros( 4, 1 );
robot_y       = zeros( 4, 1 );
robot_sigma   = zeros( 4, 1 );

full_x_plant      = zeros( 15, 1 );
full_x_hat        = zeros( 15, 1 );
full_p            = zeros( 15, 15 );
full_x_hat_camera = zeros( 15, 1 );
full_p_camera     = zeros( 15, 15 );
full_u            = zeros( 3, 1 );
camera_y          = zeros( 3, 1 );
encoder_y         = zeros( 4, 1 );

% TODO: Fix this to actually use delayed camera input etc
camera_buffer  = zeros( 3, 1 ); % Delays 0 samples for camera
u_buffer       = zeros( 3, 1 ); % 0 samples of input before camera data comes
encoder_buffer = zeros( 4, 1 ); % 0 samples of encoders before camera input comes

prev_y = 0;

for n = 0:length(time)-1
    %% Compute Controller Output
    
    % Soccer controller update
    if mod(n*t_continous_period, t_camera_period) < t_continous_period*.999
        %% Get sensor output
        camera_buffer = full_x_plant(1:3);
        encoder_buffer = robot_y;
         
        %% Update Kalman Filter
        camera_cur = camera_buffer(:, 1);
        wheel_cur  = encoder_buffer(:, 1);
        
        camera_buffer(:, 1) = [];
        encoder_buffer(:, 1) = [];
        
        % Use both camera and wheel when new camera data comes in
        z_k = [camera_cur; wheel_cur];
        
        % Use state from right before last camera input
        x_hat_k1_k1 = full_x_hat_camera;
        p_k1_k1     = full_p_camera;
        
        % TODO: Rotate
        full_u_kalman = [zeros(3,1); BotToWheel*eye(3)*full_u; zeros(8, 1)];
        
        % Predict where we should be this time step
        x_hat_k_k1 = F_k * full_x_hat + B_k * full_u_kalman;
        P_k_k1 = F_k * p_k1_k1 * F_k' + Q_k;
        
        % Get error between predicted and actual
        y_tilda_k = z_k - H_k * x_hat_k_k1;
        S_k = R_k + H_k * P_k_k1 * H_k';
        
        % Get optimal state estimator gain
        K_k = P_k_k1 * H_k' * pinv(S_k);
        
        % Update state
        x_hat_k_k = x_hat_k_k1 + K_k*y_tilda_k;
        
        %
        P_k_k = (eye(15) - K_k * H_k) * P_k_k1 * (eye(15) - K_k * H_k)' + K_k * R_k * K_k';
        y_tilda_k_k = z_k - H_k * x_hat_k_k;
        
        full_p = P_k_k;
        full_x_hat = x_hat_k_k;
        
        full_p_camera = P_k_k;
        full_x_hat_camera = x_hat_k_k;
        
        %% Update Output vel
        y = zeros(3,1);
        target = [1;0;0];
        start = [0;0;0];
        
        t_current = n*t_continous_period;
        t_start = 0;
        
        for i = 1:3
            a_c = 2; % Max Accel
            s_c = 1; % Max Speed
            t_a = s_c / a_c;

            sign = 2*(target(i) > start(i)) - 1;

            t_s = sign*(target(i) - start(i))/s_c - t_a;
            t_end = t_start + t_a + t_s + t_a;

            if (abs(start(i) - target(i)) < 0.01)
                y(i) = 0;
                continue;
            end

            if t_current < t_start
                y(i) = start(i);
            elseif t_current < t_start + t_a
                y(i) = start(i) + sign*1/2*a_c*(t_current - t_start)^2;
            elseif t_current < t_end - t_a
                y(i) = 1/2*(start(i) + target(i)) + sign*s_c*(t_current - 1/2*(t_start + t_end));
            elseif t_current < t_end
                y(i) = target(i) - sign*1/2*a_c*(t_end - t_current)^2;
            else % t_current > t_end
                y(i) = target(i);
            end
        end
        
        reference_target_vel = (y - prev_y) ./ t_camera_period;
        prev_y = y;
        
        %% Update PID
        pid_vel = [0;0;0];
        
        %% Update Output
        full_u = reference_target_vel + pid_vel;
    end
    
    % Robot controller update
    if mod(n*t_continous_period, t_robot_period) < t_continous_period*.999
        %% Get sensor output
        encoder_tick_per_rpm = 1000;
        robot_y = 1 ./ encoder_tick_per_rpm .* round(robot_x_plant * encoder_tick_per_rpm);
        
        %% Update controller state estimation
        robot_x_hat = robot_y;
        
        % TODO: Fix this so it actually rotates
        targetVel = eye(3) * full_u;
        robot_sigma = robot_sigma + t_robot_period * (BotToWheel*targetVel - robot_y);
        
        
        %% Update Output
        % State space integral controller (!!Continous gains!!)
        robot_u = -1 .* (K_int * [robot_y; robot_sigma]);
        if any(abs(robot_u) > 12)
            robot_u = robot_u ./ max(robot_u) .* 12; 
        end
    end
    
    %% Store all the results
    % Robot wheel speed controller
    robot_X_plant(:, n+1) = robot_x_plant; % Real wheel vels
    robot_X_hat(:, n+1)   = robot_x_hat; % Current estimated wheel vels
    robot_U(:, n+1)       = robot_u; % Input voltage
    robot_Y(:, n+1)       = robot_y; % Same as x
    robot_SIGMA(:, n+1)   = robot_sigma; % Error integrator
    robot_BDY_VEL(:, n+1) = WheelToBot * robot_x_plant;

    % Position controller
    full_X_hat(:, n+1)   = full_x_hat; % Estimated state vector
    full_U(:, n+1)       = full_u;  % Input velocity target
    camera_Y(:, n+1)     = camera_y;  % Camera output
    encoder_Y(:, n+1)    = robot_x_plant;  % Encoder output
    
    
    %% Plant Physics
    %body_vel = WheelToBot * robot_x_plant;
    A_cont = A;%double(subs(A_sym, phi_sym, body_vel(3)));
    B_cont = B;%double(subs(B_sym, phi_sym, body_vel(3)));
    robot_x_plant = robot_x_plant + t_continous_period*(A_cont * robot_x_plant + B_cont * robot_u);
    
    camera_y(3) = camera_y(3) + t_continous_period * [0, 0, 1] * WheelToBot * robot_x_plant;
    camera_y(1:2) = camera_y(1:2) + t_continous_period * [1, 1, 0] * eye(3) * WheelToBot * robot_x_plant; % TODO: Rotate this
end

figure(1)
subplot(411), plot(time, robot_X_plant(1,:)), xlabel('t [s]'), ylabel('\omega(t) [rad/s]');
subplot(412), plot(time, robot_X_plant(2,:)), xlabel('t [s]'), ylabel('\omega(t) [rad/s]');
subplot(413), plot(time, robot_X_plant(3,:)), xlabel('t [s]'), ylabel('\omega(t) [rad/s]');
subplot(414), plot(time, robot_X_plant(4,:)), xlabel('t [s]'), ylabel('\omega(t) [rad/s]');
subplot(411), title('Robot Wheel Velocity (Real)');

figure(2)
subplot(411), plot(time, robot_U(1,:)), xlabel('t [s]'), ylabel('V(t) [V]');
subplot(412), plot(time, robot_U(2,:)), xlabel('t [s]'), ylabel('V(t) [V]');
subplot(413), plot(time, robot_U(3,:)), xlabel('t [s]'), ylabel('V(t) [V]');
subplot(414), plot(time, robot_U(4,:)), xlabel('t [s]'), ylabel('V(t) [V]');
subplot(411), title('Robot Wheel Input Voltage');

figure(3)
subplot(411), plot(time, robot_SIGMA(1,:)), xlabel('t [s]'), ylabel('\omega(t) [rad/s]');
subplot(412), plot(time, robot_SIGMA(2,:)), xlabel('t [s]'), ylabel('\omega(t) [rad/s]');
subplot(413), plot(time, robot_SIGMA(3,:)), xlabel('t [s]'), ylabel('\omega(t) [rad/s]');
subplot(414), plot(time, robot_SIGMA(4,:)), xlabel('t [s]'), ylabel('\omega(t) [rad/s]');
subplot(411), title('Robot Wheel Controller Sigma');

figure(4)
subplot(311), plot(time, robot_BDY_VEL(1,:)), xlabel('t [s]'), ylabel('v(t) [m/s]');
subplot(312), plot(time, robot_BDY_VEL(2,:)), xlabel('t [s]'), ylabel('v(t) [m/s]');
subplot(313), plot(time, robot_BDY_VEL(3,:)), xlabel('t [s]'), ylabel('v(t) [m/s]');
subplot(311), title('Robot Body Velocity');

figure(5)
subplot(311), plot(time, full_U(1,:)), xlabel('t [s]'), ylabel('v(t) [m/s]');
subplot(312), plot(time, full_U(2,:)), xlabel('t [s]'), ylabel('v(t) [m/s]');
subplot(313), plot(time, full_U(3,:)), xlabel('t [s]'), ylabel('v(t) [m/s]');
subplot(311), title('Target Body Velocity');