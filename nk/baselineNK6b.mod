% NK Model with QE and IOR Policy

var y pi i_res i_loan;       % Endogenous variables
varexo eps_s;                % Supply shock

parameters sigma beta kappa phi_pi phi_y m B_cb alpha r_n;

sigma = 1;          % Intertemporal elasticity
beta = 0.99;        % Discount factor
kappa = 0.1;        % Phillips curve slope
phi_pi = 1.5;       % Inflation response
phi_y = 0.125;      % Output response
m = 0.5;            % Pre-QE spread
B_cb = 2.0;         % QE bond holdings
alpha = 0.2;        % QE spread effect
r_n = 0.01;         % Natural rate

model;
    % Loan rate with QE-compressed spread
    i_loan = i_res + (m - alpha*B_cb);

    % IS curve
    y = y(+1) - sigma*(i_loan - pi(+1) - r_n);

    % Phillips curve
    pi = beta*pi(+1) + kappa*y + eps_s;

    % Taylor rule for IOR
    i_res = phi_pi*pi + phi_y*y + r_n;
end;

shocks;
    var eps_s = 0.1^2;     % Supply shock (e.g., oil price spike)
end;

steady_state_model;
    y = 0;
    pi = 0;
    i_res = r_n;
    i_loan = i_res + (m - alpha*B_cb);
end;

steady;
check;
stoch_simul(irf=20);