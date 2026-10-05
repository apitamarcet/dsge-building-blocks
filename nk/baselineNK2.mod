
% Standard New Keynesian model with an endogenous labor market


// MODEL DEFINITION
var N i Y pi w eps_i;       // Endogenous variables 
varexo var_eps_i;           // Exogenous shocks: monetary policy 

// PARAMETERS
parameters sigma beta eta phi_pi kappa mu A Y_ss rho_i pi_ss; 

// PARAMETER CALIBRATION (example values)
sigma = 2;          // Risk aversion
beta = 0.99;        // Discount factor
eta = 2;          // Inverse Frisch elasticity 
phi_pi = 1.5;       // Taylor rule weight on inflation
kappa = 0.1;       // Slope of Phillips Curve
mu = 1.2;           // Steady-state markup
A = 1.021;              // Technology level (constant)
rho_i = 0.9;        // Persistence of MP shock
Y_ss = 1.0;         // Steady-state output CHECK
pi_ss = 0.0025;     // Steady-state inflation (target)


// MODEL EQUATIONS (9 equations for 9 variables)
model;
  // 1. Household FOC for consumption (Euler equation)
  Y^(-sigma) = beta * (1 + i) * Y(+1)^(-sigma) / (1 + pi(+1));

  // 2. Household FOC for labor (real wage = MRS)
  w = Y^sigma * N^eta;

  // 3. Monetary policy rule (Taylor rule)
  i = phi_pi * (pi - pi_ss) + eps_i; 

  // 4. Production function (no capital)
  Y = A * N;

  // 5. New Keynesian Phillips Curve
  pi = beta * pi(+1) + kappa * w;

  // 6. Monetary policy shock
  eps_i = rho_i * eps_i(-1) + var_eps_i;

end;

// STEADY-STATE INITIALIZATION (simplified)
initval;
  Y = Y_ss;
  N = Y_ss / A;
  i = 0;
  pi = pi_ss;
  w = (Y^sigma * N^eta); // From labor FOC
end;

steady; // Solve for steady state
check; 

// SHOCKS
shocks;
  var var_eps_i = 0.01^2;  // Variance of MP shock
end;

// SIMULATION
stoch_simul(order=1, irf=20);