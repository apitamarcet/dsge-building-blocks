
% Standard New Keynesian model with government (lump-sum tax)


// MODEL DEFINITION

% Declare endogenous variables (output gap, inflation, interest rate, MP shock, government spending)
var y pi i v g;

% Declare exogenous shocks (monetary policy shock, government spending shock)
varexo eps_v eps_g;

% Declare parameters
parameters beta sigma kappa phi_pi phi_y rho_v rho_g;
%parameters sigma beta phi_pi g_share G_ss rho_g kappa mu A rho_i Y_ss pi_ss; 

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

% Parameter values
beta = 0.99;       % Discount factor
sigma = 2;         % Relative risk aversion (1/IES)
kappa = 0.1;       % Slope of Phillips curve
phi_pi = 1.5;      % Taylor rule response to inflation
phi_y = 0.125;     % Taylor rule response to output gap
rho_v = 0.3;       % Persistence of monetary policy shock
rho_g = 0.8;       % Persistence of government spending shock


% Model equations
// MODEL EQUATIONS (9 equations for 9 variables)
model(linear);
  // 1. Household FOC for consumption (Euler equation)
  %(Y-G)^(-sigma) = beta * (1 + i) * (Y(+1) - G(+1))^(-sigma) / (1 + pi(+1));
  y = y(+1) - 1/sigma*(i - pi(+1)) + (g - g(+1))/sigma;

  // 2. Monetary policy rule (Taylor rule)
  %i = phi_pi * (pi - pi_ss) + eps_i; 
  i = phi_pi*pi  + v; %+ phi_y*y

  // 3. New Keynesian Phillips Curve
  %pi = kappa * (Y - Y_ss) + beta * pi(+1);
  pi = kappa*y + beta*pi(+1);

  // 4. Government Budget Constraint
  %G = T;

  // 5. Fiscal Policy shock
  %G = G_ss + rho_g*(G(-1) - G_ss) + var_eps_g;
  g = rho_g*g(-1) + eps_g;

  // 6. Monetary policy shock
  %eps_i = rho_i * eps_i(-1) + var_eps_i;
  v = rho_v*v(-1) + eps_v;  
end;

% // STEADY-STATE INITIALIZATION (simplified)
% initval;
%   Y = Y_ss;
%   G = G_ss;
%   T = G_ss;
%   i = 0;
%   pi = pi_ss;
% end;

steady; // Solve for steady state
check; 

// SHOCKS
shocks;
  %var var_eps_i = 0.01^2;  // Variance of MP shock
  var eps_v = 0.0625;   % Variance of MP shock
  %var var_eps_g = 0.01^2;  // Variance of FP shock
  var eps_g = 0.0625;   % Variance of government spending shock
end;

// SIMULATION
%stoch_simul(order=1, irf=20);
% Simulate impulse responses
stoch_simul(periods=1000, irf=12, order=1);