% Standard Three-Equation New Keynesian Model

% Declare endogenous variables (output gap, inflation, interest rate)
var y pi i v ; % r;

% Declare exogenous shocks (demand shock, cost-push shock, monetary policy shock)
varexo eps_v;

% Declare parameters
parameters beta sigma kappa phi_pi phi_y rho_v;
%parameters beta kappa phi_pi phi_y rho_d rho_s rho_m sigma rn;

% Parameter values
beta = 0.99;       % Discount factor
sigma = 2;         % relative risk aversion (1/IES)
kappa = 0.1;       % Slope Phillips curve
phi_pi = 1.5;      % Taylor rule response to inflation
phi_y = 0.125;     % Taylor rule response to output gap
%rho_d = 0.8;       % Persistence of demand shock
%rho_s = 0.5;       % Persistence of cost-push shock
rho_v = 0.3;       % Persistence of monetary policy shock
%rn = 0.02;         % Natural interest rate

% Model equations
model(linear);
    %// Monetary Policy (Taylor-Rule type)
    i = phi_pi*pi + phi_y*y + v; 
    
    %// NKIS-Equation
    y = y(+1) - 1/sigma*(i-pi(+1));
    
    %// NK Phillips Curve
    pi = kappa*y + beta*pi(+1);

    %// Shock processes (AR(1))
    v = rho_v*v(-1) + eps_v;
    
    %// Real rate 
    %r = i - pi(+1);
end;


% Steady-state computation
steady;

% Check Blanchard-Kahn conditions
check;

%Define stochastic shocks
shocks;
    var eps_v = 0.0625; 
end;

% Simulate impulse responses
stoch_simul(periods=1000,irf=12,order=1);
