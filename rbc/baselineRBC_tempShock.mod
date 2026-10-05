// Standard Real Business Cycle Model in Dynare - TEMPORARY SHOCK VERSION
// This .mod file implements the basic RBC model with temporary technology shocks (rho_z = 0)

// Variable declarations
var 
    y       // Output
    c       // Consumption  
    k       // Capital stock
    n       // Labor hours
    i       // Investment
    r       // Real interest rate
    w       // Real wage
    z       // Technology shock (log)
    ;

// Exogenous shock
varexo 
    e_z     // Technology shock innovation
    ;

// Parameter declarations
parameters 
    beta    // Discount factor
    alpha   // Capital share
    delta   // Depreciation rate
    sigma   // Risk aversion coefficient
    phi     // Inverse Frisch elasticity
    rho_z   // AR(1) coefficient for technology
    sigma_z // Standard deviation of technology shock
    ;

// Parameter calibration (standard RBC values with temporary shock)
beta    = 0.99;     // Quarterly discount factor
alpha   = 0.36;     // Capital share in production
delta   = 0.025;    // Quarterly depreciation rate
sigma   = 2;        // Risk aversion
phi     = 2;        // Inverse Frisch elasticity of labor supply
rho_z   = 0;        // NO persistence - temporary shock only!
sigma_z = 0.05;     // Standard deviation of technology innovation

// Model equations
model;
    // 1. Euler equation (consumption)
    c^(-sigma) = beta * c(+1)^(-sigma) * (1 + r(+1) - delta);
    
    // 2. Labor supply condition
    c^(-sigma) * w = n^phi;
    
    // 3. Production function
    y = exp(z) * k(-1)^alpha * n^(1-alpha);
    
    // 4. Marginal product of capital (real interest rate)
    r = alpha * exp(z) * k(-1)^(alpha-1) * n^(1-alpha);
    
    // 5. Marginal product of labor (real wage)
    w = (1-alpha) * exp(z) * k(-1)^alpha * n^(-alpha);
    
    // 6. Resource constraint
    y = c + i;
    
    // 7. Capital accumulation
    k = (1-delta) * k(-1) + i;
    
    // 8. Technology process (temporary shock - no persistence)
    z = rho_z * z(-1) + e_z;
end;

// Initial values for steady state computation
initval;
    z = 0;
    k = 9;
    n = 0.33;
    y = 1;
    c = 0.8;
    i = 0.2;
    r = 0.035;
    w = 2;
end;

// Compute steady state
steady;

// Check Blanchard-Kahn conditions
check;

// Shock specification
shocks;
    var e_z = sigma_z^2;
end;

// Stochastic simulation - compute IRFs only
stoch_simul(order=1, irf=40, noprint, nograph) y c i;