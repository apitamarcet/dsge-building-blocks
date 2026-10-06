% New Keynesian model with interest on reserves and a QE-compressed loan spread
% Linear model in deviations from steady state.
% The central bank sets the interest rate on reserves (IOR) by a Taylor rule.
% The loan rate relevant for demand equals the IOR plus a spread; central bank
% bond holdings (QE) compress the spread.

var y pi i_res i_loan spread B_cb;   % output gap, inflation, IOR, loan rate, loan spread, QE holdings
varexo eps_s eps_B;                  % supply (cost-push) shock, QE shock

parameters sigma beta kappa phi_pi phi_y alpha rho_B;

sigma  = 1;       % interest sensitivity of demand
beta   = 0.99;    % discount factor
kappa  = 0.1;     % Phillips curve slope
phi_pi = 1.5;     % Taylor rule response to inflation
phi_y  = 0.125;   % Taylor rule response to the output gap
alpha  = 0.2;     % spread compression per unit of QE
rho_B  = 0.9;     % persistence of QE holdings

model(linear);
    % Loan rate = IOR + spread
    i_loan = i_res + spread;

    % Loan spread compressed by QE
    spread = -alpha*B_cb;

    % IS curve: demand depends on the loan rate
    y = y(+1) - sigma*(i_loan - pi(+1));

    % Phillips curve with cost-push shock
    pi = beta*pi(+1) + kappa*y + eps_s;

    % Taylor rule for the interest on reserves
    i_res = phi_pi*pi + phi_y*y;

    % QE holdings: AR(1)
    B_cb = rho_B*B_cb(-1) + eps_B;
end;

shocks;
    var eps_s = 0.1^2;    % supply shock (e.g. oil price spike)
    var eps_B = 0.1^2;    % QE shock
end;

steady;
check;
stoch_simul(irf=20) y pi i_res i_loan spread B_cb;
