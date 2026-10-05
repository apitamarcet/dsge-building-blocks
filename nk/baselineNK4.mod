
% Standard New Keynesian model with endogenous labor market and government that collects a lump sum tax


var N i Y pi w eps_i G tau_l;
varexo var_eps_i var_eps_g;

parameters sigma beta eta phi_pi kappa mu A Y_ss rho_i pi_ss g_share rho_g G_ss;

// Revised Calibration (example)
sigma = 2;
beta = 0.99;
eta = 2;
phi_pi = 1.5;
kappa = 0.05;    // Reduced kappa
mu = 1.2;
A = 1.021;
Y_ss = 1.0;
pi_ss = 0.01;    // Increased pi_ss
rho_i = 0.9;
g_share = 0.2;
G_ss = g_share * Y_ss;
rho_g = 0.9;

model;

  // 1. Euler Equation (adjusted for C = Y - G)
  (Y - G)^(-sigma) = beta * (1 + i) * (Y(+1) - G(+1))^(-sigma) / (1 + pi(+1));
  
  // 2. Labor FOC (adjusted for C)
  w*(1 - G/(w*N)) = (Y - G)^sigma * N^eta;
  %w*(1-tau) = (Y - G)^sigma * N^eta;
  // 3. Taylor Rule
  i = phi_pi * (pi - pi_ss) + eps_i;

  // 4. Production Function
  Y = A * N;

  // 5. NK Phillips Curve
  pi = beta * pi(+1) + kappa * (Y-Y_ss);

  // 6. Monetary Policy Shock
  eps_i = rho_i * eps_i(-1) + var_eps_i;

  // 7. Government Budget Constraint
  tau_l*w*N = G;

  // 8. Government Spending Process
  G = G_ss + rho_g*(G(-1) - G_ss) + var_eps_g;
end;

initval;
  Y = Y_ss;
  N = Y_ss / A;
  i = ((1 + pi_ss)/beta) - 1;
  pi = pi_ss;
  w = (1 - beta)*pi_ss / kappa;  // From NK Phillips curve
  tau_l = G_ss / (w * N);          // Solve for tau
  G = G_ss;
  eps_i = 0;
end;

steady;
check;

shocks;
  var var_eps_i = 0.01^2;
  var var_eps_g = 0.01^2; // Government spending shock variance
end;

stoch_simul(order=1, irf=20);