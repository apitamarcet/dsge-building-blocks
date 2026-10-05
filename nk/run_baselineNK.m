% run_baselineNK.m
% Runs one of the New Keynesian model variants in this folder.
% Dynare must be on the MATLAB path, e.g. addpath('<dynare-folder>/matlab').
% Uncomment the model you want to run.

dynare baselineNK.mod       % 3-equation NK model (y, pi, i)
%dynare baselineNK1.mod     % + government: lump-sum tax, spending follows an AR(1)
%dynare baselineNK1b.mod    % + government: consumption tax, spending follows an AR(1)
%dynare baselineNK2.mod     % + endogenous labour market (y, pi, i, n, w)
%dynare baselineNK3.mod     % + labour market + government with lump-sum tax (nonlinear)
%dynare baselineNK3b.mod    % + labour market + government with consumption tax (linear)
%dynare baselineNK4.mod     % + labour market + government with labour-income tax
%dynare baselineNK6.mod     % + long-term rate, term premium and QE
%dynare baselineNK6b.mod    % + interest on reserves and QE-compressed loan spread
