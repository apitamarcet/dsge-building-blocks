% baselineNK_diff_price_stickiness.mod
% Standard Three-Equation New Keynesian Model with Price Stickiness Variation

% Declare endogenous variables
var y pi i d s;

% Declare exogenous shocks
varexo eps_d eps_s;

% Declare parameters
parameters beta sigma kappa phi_pi phi_y rho_d rho_s;

% Load parameters from MATLAB workspace
load('temp_params.mat');
set_param_value('beta', beta);
set_param_value('sigma', sigma);
set_param_value('kappa', kappa);
set_param_value('phi_pi', phi_pi);
set_param_value('phi_y', phi_y);
set_param_value('rho_d', rho_d);
set_param_value('rho_s', rho_s);

% Model equations
model(linear);
    % IS Equation (Dynamic IS curve)
    y = y(+1) - (1/sigma)*(i - pi(+1)) + d;
    
    % Phillips Curve
    pi = kappa*y + beta*pi(+1) + s;
    
    % Monetary Policy Rule (Taylor Rule)
    i = phi_pi*pi + phi_y*y;
    
    % Demand shock process
    d = rho_d*d(-1) + eps_d;
    
    % Supply shock process
    s = rho_s*s(-1) + eps_s;
end;

% Initial values (all variables start at steady state = 0 in linear model)
initval;
    y = 0;
    pi = 0;
    i = 0;
    d = 0;
    s = 0;
end;

% Compute steady state
steady;

% Check Blanchard-Kahn conditions
check;

% Define variance of shocks
shocks;
    var eps_d = 0.01;   % Variance of demand shock (1% standard deviation)
    var eps_s = 0.01;   % Variance of supply shock (1% standard deviation)
end;

% Compute stochastic simulation
stoch_simul(order=1, irf=12, nograph, noprint) y pi i;