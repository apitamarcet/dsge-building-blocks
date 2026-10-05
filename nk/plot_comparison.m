function plot_comparison(results, omega_values)
    % Create comprehensive comparison plots with initial values
    
    colors = lines(5);  % Use MATLAB's default color scheme
    line_styles = {'-', '--', ':', '-.'};
    num_omega = length(omega_values);
    
    % Figure 1: Demand and Supply Shock Responses
    figure('Position', [100, 100, 1400, 900]);
    
    % Create subplot layout
    shock_types = {'Demand Shock', 'Supply Shock'};
    var_names = {'Output Gap', 'Inflation', 'Interest Rate'};
    var_fields_d = {'y_eps_d', 'pi_eps_d', 'i_eps_d'};
    var_fields_s = {'y_eps_s', 'pi_eps_s', 'i_eps_s'};
    
    for row = 1:2  % Demand vs Supply
        for col = 1:3  % y, pi, i
            subplot(2, 3, (row-1)*3 + col);
            hold on;
            
            for i = 1:num_omega
                if row == 1  % Demand shock
                    irf_data = results(i).(var_fields_d{col});
                else  % Supply shock
                    irf_data = results(i).(var_fields_s{col});
                end
                
                % Add initial steady state value (0) and create proper time vector
                plot_data = [0, irf_data];
                time_periods = 0:length(irf_data);
                
                plot(time_periods, plot_data, ...
                     'Color', colors(i,:), ...
                     'LineStyle', line_styles{min(i, length(line_styles))}, ...
                     'LineWidth', 2, ...
                     'DisplayName', sprintf('ω=%.2f', omega_values(i)));
            end
            
            % Add zero line for reference
            yline(0, 'k--', 'Alpha', 0.3, 'HandleVisibility', 'off');
            
            title(sprintf('%s: %s', var_names{col}, shock_types{row}));
            xlabel('Quarters');
            ylabel('Deviation from SS (%)');
            legend('Location', 'best', 'FontSize', 9);
            grid on;
            box on;
            
            % Adjust y-limits for better visualization
            ylims = ylim;
            ylim([min(ylims(1), -0.05), max(ylims(2), 0.05)]);
        end
    end
    
    sgtitle('Monetary Policy Effectiveness Under Different Price Stickiness Levels', ...
            'FontSize', 14, 'FontWeight', 'bold');
    
    % Figure 2: Policy Trade-off Analysis
    figure('Position', [100, 100, 1200, 500]);
    
    % Calculate sacrifice ratios
    sacrifice_ratios = zeros(1, num_omega);
    volatility_ratios = zeros(1, num_omega);
    
    for i = 1:num_omega
        % Sacrifice ratio: cumulative output loss per unit inflation reduction
        cumulative_output_loss = sum(abs(results(i).y_eps_s));
        cumulative_inflation = sum(abs(results(i).pi_eps_s));
        
        if cumulative_inflation > 0
            sacrifice_ratios(i) = cumulative_output_loss / cumulative_inflation;
        else
            sacrifice_ratios(i) = 0;
        end
        
        % Volatility ratio: relative volatility of output to inflation
        volatility_ratios(i) = std(results(i).y_eps_s) / std(results(i).pi_eps_s);
    end
    
    % Subplot 1: Sacrifice Ratios
    subplot(1, 3, 1);
    bar(categorical(arrayfun(@(x) sprintf('ω=%.2f', x), omega_values, 'UniformOutput', false)), ...
        sacrifice_ratios, 'FaceColor', [0.3 0.5 0.7]);
    xlabel('Price Stickiness');
    ylabel('Sacrifice Ratio');
    title('Output Cost of Disinflation');
    grid on;
    
    % Add value labels on bars
    for i = 1:num_omega
        text(i, sacrifice_ratios(i), sprintf('%.2f', sacrifice_ratios(i)), ...
             'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    end
    
    % Subplot 2: Demand Shock Persistence
    subplot(1, 3, 2);
    persistence_demand = zeros(1, num_omega);
    for i = 1:num_omega
        % Calculate half-life of output response to demand shock
        y_response = abs(results(i).y_eps_d);
        half_value = y_response(1) / 2;
        half_life_idx = find(y_response < half_value, 1);
        if isempty(half_life_idx)
            persistence_demand(i) = length(y_response);
        else
            persistence_demand(i) = half_life_idx;
        end
    end
    
    bar(categorical(arrayfun(@(x) sprintf('ω=%.2f', x), omega_values, 'UniformOutput', false)), ...
        persistence_demand, 'FaceColor', [0.7 0.5 0.3]);
    xlabel('Price Stickiness');
    ylabel('Half-life (quarters)');
    title('Demand Shock Persistence');
    grid on;
    
    % Add value labels
    for i = 1:num_omega
        text(i, persistence_demand(i), sprintf('%d', persistence_demand(i)), ...
             'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    end
    
    % Subplot 3: Phillips Curve Slope
    subplot(1, 3, 3);
    kappa_values = zeros(1, num_omega);
    for i = 1:num_omega
        kappa_values(i) = results(i).kappa;
    end
    
    bar(categorical(arrayfun(@(x) sprintf('ω=%.2f', x), omega_values, 'UniformOutput', false)), ...
        kappa_values, 'FaceColor', [0.5 0.7 0.3]);
    xlabel('Price Stickiness');
    ylabel('κ (Phillips Curve Slope)');
    title('Price Flexibility Parameter');
    grid on;
    
    % Add value labels
    for i = 1:num_omega
        text(i, kappa_values(i), sprintf('%.3f', kappa_values(i)), ...
             'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    end
    
    sgtitle('Policy Trade-offs and Model Parameters', 'FontSize', 14, 'FontWeight', 'bold');
    
    % Figure 3: Cumulative Responses
    figure('Position', [100, 100, 1200, 600]);
    
    for shock = 1:2
        for var = 1:3
            subplot(2, 3, (shock-1)*3 + var);
            hold on;
            
            for i = 1:num_omega
                if shock == 1
                    irf_data = results(i).(var_fields_d{var});
                else
                    irf_data = results(i).(var_fields_s{var});
                end
                
                % Calculate cumulative response
                cumulative = cumsum([0, irf_data]);
                
                plot(0:length(irf_data), cumulative, ...
                     'Color', colors(i,:), ...
                     'LineStyle', line_styles{min(i, length(line_styles))}, ...
                     'LineWidth', 2, ...
                     'DisplayName', sprintf('ω=%.2f', omega_values(i)));
            end
            
            yline(0, 'k--', 'Alpha', 0.3, 'HandleVisibility', 'off');
            
            title(sprintf('Cumulative %s: %s', var_names{var}, shock_types{shock}));
            xlabel('Quarters');
            ylabel('Cumulative Deviation');
            legend('Location', 'best', 'FontSize', 9);
            grid on;
            box on;
        end
    end
    
    sgtitle('Cumulative Impulse Responses', 'FontSize', 14, 'FontWeight', 'bold');
    
    % Print summary statistics
    fprintf('\n========================================\n');
    fprintf('SUMMARY STATISTICS\n');
    fprintf('========================================\n\n');
    
    for i = 1:num_omega
        fprintf('Price Stickiness (ω = %.2f):\n', omega_values(i));
        fprintf('  Phillips Curve Slope (κ): %.4f\n', results(i).kappa);
        fprintf('  Sacrifice Ratio: %.3f\n', sacrifice_ratios(i));
        fprintf('  Demand Shock Half-life: %d quarters\n', persistence_demand(i));
        fprintf('  Max Output Response (Demand): %.3f%%\n', max(abs(results(i).y_eps_d))*100);
        fprintf('  Max Inflation Response (Supply): %.3f%%\n', max(abs(results(i).pi_eps_s))*100);
        fprintf('\n');
    end
end