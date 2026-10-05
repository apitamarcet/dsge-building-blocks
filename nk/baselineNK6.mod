% New Keynesian Model with QE

var y pi i iL TP B;   % Endogenous variables
varexo eps_TP eps_B;  % Exogenous shocks (term premium, QE)

parameters sigma beta kappa rho theta phi_pi phi_y psi L rn;

sigma = 2;          % Intertemporal elasticity
beta = 0.99;        % Discount factor
kappa = 0.1;        % Phillips curve slope
rho = 0.8;          % Long-rate persistence
theta = 0.2;        % QE effectiveness
phi_pi = 1.5;       % Taylor rule (inflation)
phi_y = 0.125;      % Taylor rule (output)
psi = 0.5;          % QE responsiveness
L = 1;              % Total long-term bonds (normalized)
rn = 0.02;

model;
    % IS Curve (depends on long-term rate)
    y = y(+1) - (1/sigma)*(iL - pi(+1) - rn);

    % Phillips Curve
    pi = beta*pi(+1) + kappa*y;

    % Term Structure Equation
    iL = (1 - rho)*i + rho*iL(+1) + TP;

    % Term Premium (QE reduces TP)
    TP = -theta*(B/L) + eps_TP;

    % Central Bank Policy
    % Short-term rate (Taylor rule with ZLB)
    i = max(0, rn + phi_pi*pi + phi_y*y);

    % QE Rule (active at ZLB)
    B = psi*(y + pi) + eps_B;

    % Natural rate (exogenous shock)
    rn = 0.01 + 0.9*(rn(-1) - 0.01);  % Example AR(1) process
end;

shocks;
    var eps_TP = 0.1^2;    % Term premium shock
    var eps_B = 0.1^2;     % QE shock
end;

steady;
check;
stoch_simul(irf=20);