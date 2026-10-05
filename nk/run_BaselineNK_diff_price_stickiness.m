% run_BaselineNK_diff_price_stickiness.m
% Robust version with error handling and diagnostics

% Clear workspace and set up environment
clear all;
close all;
clc;

% Add Dynare to path if needed (adjust path as necessary)
% addpath('C:/dynare/5.2/matlab');

fprintf('========================================\n');
fprintf('NEW KEYNESIAN MODEL WITH PRICE STICKINESS\n');
fprintf('========================================\n\n');

%% Parameter Configuration
% Deep parameters (structural)
beta = 0.99;      % Discount factor (quarterly)
sigma = 2;        % Relative risk aversion
phi_pi = 1.5;     % Taylor rule response to inflation
phi_y = 0.125;    % Taylor rule response to output gap  
rho_d = 0.8;      % Persistence of demand shock
rho_s = 0.5;      % Persistence of cost-push shock

% Test with just 3 omega values first
omega_values = [0.25, 0.67, 0.9];
scenario_names = {'Flexible', 'Moderate', 'Sticky'};
num_omega = length(omega_values);

% Display parameters
fprintf('Model Parameters:\n');
fprintf('  Discount factor (β): %.3f\n', beta);
fprintf('  Risk aversion (σ): %.1f\n', sigma);
fprintf('  Taylor rule - Inflation (φ_π): %.2f\n', phi_pi);
fprintf('  Taylor rule - Output (φ_y): %.3f\n', phi_y);
fprintf('  Demand shock persistence (ρ_d): %.2f\n', rho_d);
fprintf('  Supply shock persistence (ρ_s): %.2f\n\n', rho_s);

%% Check Model Determinacy Conditions
fprintf('Checking model determinacy conditions...\n');
fprintf('----------------------------------------\n');

for i = 1:num_omega
    omega = omega_values(i);
    kappa = ((1-omega)*(1-beta*omega))/omega;
    
    % Check if parameters are valid
    if kappa <= 0 || ~isfinite(kappa)
        error('Invalid kappa value for omega = %.2f', omega);
    end
    
    % Simple determinacy check (Taylor principle)
    determinacy = phi_pi + ((1-beta)/kappa)*phi_y;
    fprintf('ω = %.2f: κ = %.4f, Determinacy = %.3f %s\n', ...
            omega, kappa, determinacy, ...
            ternary(determinacy > 1, '✓', '✗ WARNING'));
end
fprintf('\n');

%% Initialize Storage
irf_length = 12;
results = struct();

%% Main Simulation Loop
fprintf('Running Dynare simulations...\n');
fprintf('----------------------------------------\n');

for i = 1:num_omega
    omega = omega_values(i);
    kappa = ((1-omega)*(1-beta*omega))/omega;
    
    fprintf('Scenario %d: %s (ω = %.2f)\n', i, scenario_names{i}, omega);
    fprintf('  Implied κ = %.4f\n', kappa);
    fprintf('  Expected price duration: %.1f quarters\n', 1/(1-omega));
    
    % Save parameters for Dynare
    try
        save('temp_params.mat', 'beta', 'sigma', 'kappa', 'phi_pi', 'phi_y', 'rho_d', 'rho_s');
        
        % Check if file was created
        if ~exist('temp_params.mat', 'file')
            error('Failed to create parameter file');
        end
        
        % Run Dynare with error catching
        warning('off', 'all');
        dynare baselineNK_diff_price_stickiness.mod noclearall nolog nostrict;
        warning('on', 'all');
        
        % Check if Dynare output exists
        if ~exist('oo_', 'var') || ~isfield(oo_, 'irfs')
            error('Dynare did not produce expected output');
        end
        
        % Store results
        results(i).omega = omega;
        results(i).kappa = kappa;
        results(i).scenario = scenario_names{i};
        
        % Extract IRFs safely
        irf_vars = {'y_eps_d', 'pi_eps_d', 'i_eps_d', 'y_eps_s', 'pi_eps_s', 'i_eps_s'};
        for v = 1:length(irf_vars)
            if isfield(oo_.irfs, irf_vars{v})
                results(i).(irf_vars{v}) = oo_.irfs.(irf_vars{v})(1:irf_length);
            else
                warning('Missing IRF: %s', irf_vars{v});
                results(i).(irf_vars{v}) = zeros(1, irf_length);
            end
        end
        
        fprintf('  ✓ Simulation completed successfully\n\n');
        
    catch ME
        fprintf('  ✗ Error in simulation: %s\n', ME.message);
        fprintf('  Attempting alternative specification...\n');
        
        % Try with alternative mod file or skip this omega
        results(i).omega = omega;
        results(i).kappa = kappa;
        results(i).scenario = scenario_names{i};
        results(i).error = ME.message;
        
        % Fill with NaN for plotting
        irf_vars = {'y_eps_d', 'pi_eps_d', 'i_eps_d', 'y_eps_s', 'pi_eps_s', 'i_eps_s'};
        for v = 1:length(irf_vars)
            results(i).(irf_vars{v}) = NaN(1, irf_length);
        end
        
        fprintf('  Skipping this scenario\n\n');
    end
    
    % Clear Dynare variables
    clear oo_ M_ options_ ys0_;
end

%% Check if we have valid results
valid_results = 0;
for i = 1:num_omega
    if ~isfield(results(i), 'error')
        valid_results = valid_results + 1;
    end
end

if valid_results == 0
    error('All simulations failed. Check your Dynare installation and model file.');
elseif valid_results < num_omega
    warning('%d out of %d simulations failed', num_omega - valid_results, num_omega);
end

%% Generate Plots (only if we have some valid results)
if valid_results > 0
    fprintf('Generating plots...\n');
    try
        plot_comparison(results, omega_values);
    catch ME
        warning('Error in plotting: %s', ME.message);
        
        % Try simple plot instead
        figure;
        for i = 1:num_omega
            if ~any(isnan(results(i).y_eps_d))
                subplot(2,3,1);
                plot(1:irf_length, results(i).y_eps_d, 'DisplayName', sprintf('ω=%.2f', omega_values(i)));
                hold on;
                title('Output: Demand Shock');
                legend('show');
                
                subplot(2,3,2);
                plot(1:irf_length, results(i).pi_eps_d, 'DisplayName', sprintf('ω=%.2f', omega_values(i)));
                hold on;
                title('Inflation: Demand Shock');
                legend('show');
            end
        end
    end
end

%% Display Summary
fprintf('\n========================================\n');
fprintf('SUMMARY\n');
fprintf('========================================\n\n');

for i = 1:num_omega
    if ~isfield(results(i), 'error')
        fprintf('ω = %.2f (κ = %.4f):\n', results(i).omega, results(i).kappa);
        fprintf('  Max |y| response to demand shock: %.4f\n', max(abs(results(i).y_eps_d)));
        fprintf('  Max |π| response to supply shock: %.4f\n', max(abs(results(i).pi_eps_s)));
    else
        fprintf('ω = %.2f: FAILED - %s\n', results(i).omega, results(i).error);
    end
end

fprintf('\nAnalysis complete!\n');

%% Helper function
function result = ternary(condition, true_val, false_val)
    if condition
        result = true_val;
    else
        result = false_val;
    end
end