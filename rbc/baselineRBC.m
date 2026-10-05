dynare baselineRBC

% Custom IRF plotting
figure;

% Make the figure wide and short
set(gcf, 'Position', [100, 100, 1100, 250]);

% Adjust spacing manually
tiledlayout(1,3, 'Padding', 'compact', 'TileSpacing', 'compact');

% Define font size for all labels/ticks
labelFontSize = 14;
tickFontSize = 12;

T = 35;%length(oo_.irfs.y_e_z);
x = 1:T;

nexttile;
plot(oo_.irfs.y_e_z, 'k', 'LineWidth', 1.7);
title('Output', 'FontSize', labelFontSize);
%xlabel('Periods', 'FontSize', labelFontSize);
%ylabel('Deviation from steady state', 'FontSize', labelFontSize);
ytickformat('%.2f');
set(gca, 'FontSize', tickFontSize);
xlim([1 T]);
grid on;

nexttile;
plot(oo_.irfs.c_e_z, 'k', 'LineWidth', 1.7);
title('Consumption', 'FontSize', labelFontSize);
%xlabel('Periods', 'FontSize', labelFontSize);
%ylabel('Deviation from steady state', 'FontSize', labelFontSize);
ytickformat('%.2f');
set(gca, 'FontSize', tickFontSize);
xlim([1 T]);
grid on;

nexttile;
plot(oo_.irfs.i_e_z, 'k', 'LineWidth', 1.7);
title('Investment', 'FontSize', labelFontSize);
%xlabel('Periods', 'FontSize', labelFontSize);
%ylabel('Deviation from steady state', 'FontSize', labelFontSize);
ytickformat('%.2f');
set(gca, 'FontSize', tickFontSize);
xlim([1 T]);
grid on;

% Save high-resolution PDF
exportgraphics(gcf, 'IRFs_base_yci.png', 'ContentType', 'vector');









% Save baseline results (rho_z = 0.95)
baseline_y = oo_.irfs.y_e_z;
baseline_c = oo_.irfs.c_e_z;
baseline_i = oo_.irfs.i_e_z;

% Run temporary shock model (rho_z = 0)
dynare baselineRBC_tempShock noclearall;

% Store temporary shock results
temp_y = oo_.irfs.y_e_z;
temp_c = oo_.irfs.c_e_z;
temp_i = oo_.irfs.i_e_z;

% Create comparison plot
figure;
% Make the figure wide and short
set(gcf, 'Position', [100, 400, 1100, 250]);
% Adjust spacing manually
tiledlayout(1,3, 'Padding', 'compact', 'TileSpacing', 'compact');

% Define font size for all labels/ticks
labelFontSize = 14;
tickFontSize = 12;
T = 35;
x = 1:T;

% Output comparison
nexttile;
hold on;
plot(baseline_y(1:T), 'k-', 'LineWidth', 1.8, 'DisplayName', '\rho=0.95');
plot(temp_y(1:T), 'k--', 'LineWidth', 1.8, 'DisplayName', '\rho=0');
hold off;
title('Output', 'FontSize', labelFontSize);
ytickformat('%.2f');
set(gca, 'FontSize', tickFontSize);
xlim([1 T]);
grid on;
legend('Location', 'northeast', 'FontSize', 10);
leg2 = legend;
leg2.Position(2) = leg2.Position(2) + 0.03;

% Consumption comparison
nexttile;
hold on;
plot(baseline_c(1:T), 'k-', 'LineWidth', 1.8, 'DisplayName', '\rho=0.95');
plot(temp_c(1:T), 'k--', 'LineWidth', 1.8, 'DisplayName', '\rho=0');
hold off;
title('Consumption', 'FontSize', labelFontSize);
ytickformat('%.2f');
set(gca, 'FontSize', tickFontSize);
xlim([1 T]);
grid on;
legend('Location', 'northeast', 'FontSize', 10);
leg2 = legend;
leg2.Position(2) = leg2.Position(2) + 0.03;

% Investment comparison
nexttile;
hold on;
plot(baseline_i(1:T), 'k-', 'LineWidth', 1.8, 'DisplayName', '\rho=0.95');
plot(temp_i(1:T), 'k--', 'LineWidth', 1.8, 'DisplayName', '\rho=0');
hold off;
title('Investment', 'FontSize', labelFontSize);
ytickformat('%.2f');
set(gca, 'FontSize', tickFontSize);
xlim([1 T]);
i_max = max([max(baseline_i(1:T)), max(temp_i(1:T))]);
ylim([-0.005, i_max * 1.05]);
grid on;
legend('Location', 'northeast', 'FontSize', 10);
leg2 = legend;
leg2.Position(2) = leg2.Position(2) + 0.03;

% Save high-resolution PNG
exportgraphics(gcf, 'IRFs_base_persistent_vs_temporary_yci.png', 'ContentType', 'vector');