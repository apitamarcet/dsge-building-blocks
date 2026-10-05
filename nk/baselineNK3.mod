
% Standard New Keynesian model with endogenous labor market and government that collects a lump sum tax


var N i Y pi w eps_i G T;       // Endogenous variables (added G and T)
varexo var_eps_i var_eps_g;     // Exogenous shocks (added var_eps_g)

parameters sigma beta eta phi_pi kappa mu A Y_ss rho_i pi_ss g_share rho_g G_ss w_ss;

// Parameter Calibration
sigma = 2;
beta = 0.99;
eta = 2;
phi_pi = 1.5;
kappa = 0.1;
mu = 1.2;
A = 1.021;
Y_ss = 1.0;
pi_ss = 0.0025;
rho_i = 0.9;
g_share = 0.2;       // Government spending as 20% of Y_ss
G_ss = g_share * Y_ss;
rho_g = 0.9;         // Persistence of government spending shock
w_ss = (1 - beta) * pi_ss / kappa ;

model;
  // 1. Euler Equation (adjusted for C = Y - G)
  (Y - G)^(-sigma) = beta * (1 + i) * (Y(+1) - G(+1))^(-sigma) / (1 + pi(+1));

  // 2. Labor FOC (adjusted for C)
  w = (Y - G)^sigma * N^eta;

  // 3. Taylor Rule
  i = phi_pi * (pi - pi_ss) + eps_i;

  // 4. Production Function
  Y = A * N;

  // 5. NK Phillips Curve
  pi = beta * pi(+1) + kappa * (Y-Y_ss);

  // 6. Monetary Policy Shock
  eps_i = rho_i * eps_i(-1) + var_eps_i;

  // 7. Government Budget Constraint
  T = G;

  // 8. Government Spending Process
  G = G_ss + rho_g*(G(-1) - G_ss) + var_eps_g;
end;

initval;
  Y = Y_ss;
  N = Y_ss / A;
  i = ((1 + pi_ss)/beta) - 1; // Steady-state interest rate
  pi = pi_ss;
  %w = (Y_ss - G_ss)^sigma * (Y_ss/A)^eta; // Steady-state wage
  w = w_ss;
  G = G_ss;
  T = G_ss;
  eps_i = 0;
end;

steady;
check;

shocks;
  var var_eps_i = 0.01^2;
  var var_eps_g = 0.01^2; // Government spending shock variance
end;

stoch_simul(order=1, irf=20);