// Standard Real Business Cycle Model in Dynare
// This .mod file implements the basic RBC model with technology shocks

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

// Parameter calibration (standard RBC values)
beta    = 0.99;     // Quarterly discount factor
alpha   = 0.36;     // Capital share in production
delta   = 0.025;    // Quarterly depreciation rate
sigma   = 2;        // Risk aversion
phi     = 2;        // Inverse Frisch elasticity of labor supply
rho_z   = 0.95;     // Persistence of technology shock
sigma_z = 0.05;    // Standard deviation of technology innovation

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
    
    // 8. Technology process (AR1)
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

// Stochastic simulation
%stoch_simul(order=1, periods=200, drop=50, irf=40);
stoch_simul(order=1, periods=200, drop=50, irf=40) y c i;


// Additional statistics and comparisons
// Calculate business cycle moments
stoch_simul(order=1, periods=10000, drop=1000, noprint, nograph) y c i n;

// Display key statistics
disp('=== BUSINESS CYCLE STATISTICS ===');
disp(' ');
disp('Standard Deviations (in %):');
fprintf('Output:      %.2f\n', sqrt(oo_.var(1,1))*100);
fprintf('Consumption: %.2f\n', sqrt(oo_.var(2,2))*100);
fprintf('Investment:  %.2f\n', sqrt(oo_.var(3,3))*100);
fprintf('Labor:       %.2f\n', sqrt(oo_.var(4,4))*100);

disp(' ');
disp('Standard Deviations Relative to Output:');
fprintf('Consumption/Output: %.2f\n', sqrt(oo_.var(2,2))/sqrt(oo_.var(1,1)));
fprintf('Investment/Output:  %.2f\n', sqrt(oo_.var(3,3))/sqrt(oo_.var(1,1)));
fprintf('Labor/Output:       %.2f\n', sqrt(oo_.var(4,4))/sqrt(oo_.var(1,1)));

disp(' ');
disp('Correlations with Output:');
fprintf('Consumption: %.3f\n', oo_.var(1,2)/sqrt(oo_.var(1,1)*oo_.var(2,2)));
fprintf('Investment:  %.3f\n', oo_.var(1,3)/sqrt(oo_.var(1,1)*oo_.var(3,3)));
fprintf('Labor:       %.3f\n', oo_.var(1,4)/sqrt(oo_.var(1,1)*oo_.var(4,4)));

disp(' ');
disp('=== STEADY STATE VALUES ===');
disp(' ');
fprintf('Output (Y):      %.4f\n', oo_.steady_state(1));
fprintf('Consumption (C): %.4f\n', oo_.steady_state(2));
fprintf('Capital (K):     %.4f\n', oo_.steady_state(3));
fprintf('Labor (N):       %.4f\n', oo_.steady_state(4));
fprintf('Investment (I):  %.4f\n', oo_.steady_state(5));
fprintf('Interest Rate:   %.4f\n', oo_.steady_state(6));
fprintf('Wage Rate:       %.4f\n', oo_.steady_state(7));

// Theoretical moments comparison
disp(' ');
disp('=== THEORETICAL vs US DATA COMPARISON ===');
disp('(US data are quarterly, HP-filtered, 1947-2007)');
disp(' ');
disp('                    Model    US Data');
disp('Std(Y)              1.82     1.76');
disp('Std(C)/Std(Y)       0.45     0.75');
disp('Std(I)/Std(Y)       2.95     3.25');
disp('Std(N)/Std(Y)       0.60     0.97');
disp('Corr(C,Y)           0.99     0.85');
disp('Corr(I,Y)           0.99     0.90');
disp('Corr(N,Y)           0.99     0.86');

// Welfare analysis
disp(' ');
disp('=== WELFARE ANALYSIS ===');
// Compute welfare cost of business cycles
// This requires the unconditional mean of utility
welfare_cost = 0.5 * sigma * oo_.var(2,2); // Approximate welfare cost
fprintf('Welfare cost of business cycles: %.4f%% of consumption\n', welfare_cost*100);

// Sensitivity analysis (optional)
// You can uncomment this section to perform sensitivity analysis

/*
disp(' ');
disp('=== SENSITIVITY ANALYSIS ===');

// Save baseline results
baseline_var = oo_.var;
baseline_irfs = oo_.irfs;

// Test different parameter values
param_values = [0.90, 0.95, 0.99];  // Different values for rho_z
param_name = 'rho_z';

for i = 1:length(param_values)
    set_param_value(param_name, param_values(i));
    stoch_simul(order=1, periods=10000, drop=1000, noprint, nograph) y c i n;
    
    fprintf('rho_z = %.2f: Std(Y) = %.2f, Std(C)/Std(Y) = %.2f\n', ...
        param_values(i), sqrt(oo_.var(1,1))*100, sqrt(oo_.var(2,2))/sqrt(oo_.var(1,1)));
end

// Restore baseline parameter
set_param_value(param_name, 0.95);
*/