% New Keynesian model with a long-term rate, term premium and QE
% Linear model in deviations from steady state.
% Demand depends on the long-term rate, which is an average of expected
% short rates plus a term premium; central bank bond purchases (QE)
% compress the term premium.

var y pi i iL TP B rn;      % output gap, inflation, short rate, long rate, term premium, QE holdings, natural rate
varexo eps_TP eps_B eps_rn; % term premium, QE and natural rate shocks

parameters sigma beta kappa rho theta phi_pi phi_y psi rho_rn;

sigma   = 2;      % relative risk aversion (1/IES)
beta    = 0.99;   % discount factor
kappa   = 0.1;    % Phillips curve slope
rho     = 0.8;    % weight on expected future long rate (long-rate persistence)
theta   = 0.2;    % term-premium compression per unit of QE
phi_pi  = 1.5;    % Taylor rule response to inflation
phi_y   = 0.125;  % Taylor rule response to the output gap
psi     = 0.5;    % QE response to the output gap and inflation (countercyclical)
rho_rn  = 0.9;    % persistence of the natural rate

model(linear);
    % IS curve: demand depends on the long-term real rate relative to the natural rate
    y = y(+1) - (1/sigma)*(iL - pi(+1) - rn);

    % Phillips curve
    pi = beta*pi(+1) + kappa*y;

    % Term structure: long rate = weighted average of current short rate and expected long rate, plus term premium
    iL = (1 - rho)*i + rho*iL(+1) + TP;

    % Term premium: QE purchases lower the premium
    TP = -theta*B + eps_TP;

    % Taylor rule for the short rate
    i = phi_pi*pi + phi_y*y;

    % QE rule: purchases rise when output and inflation fall below steady state
    B = -psi*(y + pi) + eps_B;

    % Natural rate: AR(1)
    rn = rho_rn*rn(-1) + eps_rn;
end;

shocks;
    var eps_TP = 0.1^2;   % term premium shock
    var eps_B  = 0.1^2;   % QE shock
    var eps_rn = 0.1^2;   % natural rate shock
end;

steady;
check;
stoch_simul(irf=20) y pi i iL TP B;
