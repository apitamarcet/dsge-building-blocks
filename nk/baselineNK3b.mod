% Three-Equation NK Model with Endogenous Labor and Consumption Tax (Corrected)

% Endogenous variables: y, pi, i, v, g, tau, n, w
var y pi i v g tau n w;

% Exogenous shocks: MP shock, gov spending shock
varexo eps_v eps_g;

% Parameters
parameters beta sigma phi kappa phi_pi phi_y rho_v rho_g;

% Parameter values
beta = 0.99;       % Discount factor
sigma = 2;         % Relative risk aversion
phi = 1;           % Inverse Frisch elasticity
kappa = 0.1;       % Slope of Phillips curve
phi_pi = 1.5;      % Taylor rule response to inflation
phi_y = 0.125;     % Taylor rule response to output gap
rho_v = 0.3;       % Persistence of MP shock
rho_g = 0.8;       % Persistence of gov spending shock

% Model equations
model(linear);
    % Production function (y = n)
    y = n;

    % Labor market equilibrium (MRS = MPN - tax)
    phi*n + sigma*(y - g) = w - tau;

    % Government budget constraint (τc = g)
    tau = 2*g - y;

    % Modified IS curve
    y = y(+1) - (1/sigma)*(i - pi(+1) - (tau - tau(+1))) + (g - g(+1))/sigma;

    % New Keynesian Phillips Curve
    pi = beta*pi(+1) + kappa*((phi + sigma)*y - sigma*g);

    % Taylor rule
    i = phi_pi*pi + phi_y*y + v;

    % Shock processes
    v = rho_v*v(-1) + eps_v;
    g = rho_g*g(-1) + eps_g;

    % Real wage determined by production (w = 1 in levels, 0 in logs)
    % Implicit in labor market equation - no separate identity needed
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