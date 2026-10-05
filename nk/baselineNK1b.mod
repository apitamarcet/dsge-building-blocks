% 
% % Standard New Keynesian model with government (consumption tax)
% 
% 
% // MODEL DEFINITION
% var i Y pi tau_c G eps_i;       // Endogenous variables 
% varexo var_eps_i var_eps_g;           // Exogenous shocks: monetary policy 
% 
% // PARAMETERS
% parameters sigma beta phi_pi g_share G_ss rho_g kappa mu A rho_i Y_ss pi_ss; 
% 
% // PARAMETER CALIBRATION (example values)
% sigma = 2;          // Risk aversion
% beta = 0.99;        // Discount factor
% phi_pi = 1.5;       // Taylor rule weight on inflation
% g_share = 0.2;       // Government spending as 20% of Y_ss
% Y_ss = 1.0;         // Steady-state output CHECK
% G_ss = g_share * Y_ss;
% rho_g = 0.9;         // Persistence of government spending shock
% kappa = 0.1;       // Slope of Phillips Curve
% mu = 1.2;           // Steady-state markup
% A = 1.021;              // Technology level (constant)
% rho_i = 0.9;        // Persistence of MP shoc
% pi_ss = 0.0025;     // Steady-state inflation (target)
% 
% 
% // MODEL EQUATIONS (9 equations for 9 variables)
% model;
%   // 1. Household FOC for consumption (Euler equation)
%   ((1-tau_c)*Y)^(-sigma) = beta * (1 + i) * (Y(+1) - G(+1))^(-sigma) / (1 + pi(+1));
% 
%   // 2. Monetary policy rule (Taylor rule)
%   i = phi_pi * (pi - pi_ss) + eps_i; 
% 
%   // 3. New Keynesian Phillips Curve
%   pi = beta * pi(+1) + kappa * (Y - Y_ss);
% 
%   // 4. Government Budget Constraint
%   G = tau_c*Y;
% 
%   // 5. Fiscal Policy shock
%   G = G_ss + rho_g*(G(-1) - G_ss) + var_eps_g;
% 
%   // 6. Monetary policy shock
%   eps_i = rho_i * eps_i(-1) + var_eps_i;
% 
% end;
% 
% // STEADY-STATE INITIALIZATION (simplified)
% initval;
%   Y = Y_ss;
%   G = G_ss;
%   tau_c = G_ss/Y;
%   i = 0;
%   pi = pi_ss;
% end;
% 
% steady; // Solve for steady state
% check; 
% 
% // SHOCKS
% shocks;
%   var var_eps_i = 0.01^2;  // Variance of MP shock
%   var var_eps_g = 0.01^2;  // Variance of FP shock
% end;
% 
% // SIMULATION
% stoch_simul(order=1, irf=20);


% Three-Equation NK Model with Consumption Tax

% Endogenous variables: output gap, inflation, interest rate, MP shock, gov spending, tax
var y pi i v g tau;

% Exogenous shocks: MP shock, gov spending shock
varexo eps_v eps_g;

% Parameters
parameters beta sigma kappa phi_pi phi_y rho_v rho_g;

% Parameter values
beta = 0.99;       % Discount factor
sigma = 2;         % Relative risk aversion
kappa = 0.1;       % Slope of Phillips curve
phi_pi = 1.5;      % Taylor rule response to inflation
phi_y = 0.125;     % Taylor rule response to output gap
rho_v = 0.3;       % Persistence of MP shock
rho_g = 0.8;       % Persistence of gov spending shock

% Model equations
model(linear);
    % Taylor Rule
    i = phi_pi*pi + phi_y*y + v;

    % Government Budget Constraint (τ_t c_t = g_t)
    % Log-linearized: tau = g - (y - g) = 2g - y
    tau = 2*g - y;

    % Modified IS Curve (with consumption tax effects)
    y = y(+1) - (1/sigma)*(i - pi(+1) - (tau - tau(+1)));

    % NK Phillips Curve
    pi = kappa*y + beta*pi(+1);

    % Monetary Policy Shock (AR1)
    v = rho_v*v(-1) + eps_v;

    % Government Spending Shock (AR1)
    g = rho_g*g(-1) + eps_g;
end;

% Steady-state computation
steady;

% Check Blanchard-Kahn conditions
check;

% Define stochastic shocks
shocks;
    var eps_v = 0.0625;   % MP shock variance
    var eps_g = 0.0625;   % Gov spending shock variance
end;

% Simulate impulse responses
stoch_simul(periods=1000, irf=12, order=1);