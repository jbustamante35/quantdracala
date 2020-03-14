function [X, R, P] = calculateRegression(D, S, sv)
%% calculateRegression: obtain regressor and predict data from PCA scores
%
%
% Usage:
%   [X, R, P] = calculateRegression(D, S, sv)
%
% Input:
%   D: [m x n] array of user-defined input data
%   S: PCA scores corresponding to data from D
%   sv: save results in .mat file
%
% Output:
%   X: structure containing inputted data, regressor, and predictions
%   R: regressor matrix from left-matrix divide of PCA scores and mean-corrected data
%   P: predictions based on regressor matrix R
%

%% Get mean-corrected data
meanR = mean(D);
meanC = bsxfun(@minus, D, meanR);

% Get regressor and make predictions
R = S \ meanC;
P = (S * R) + meanR;

% Save output in structure containing inputted data, regressor, and predictions
X = struct('userdata', D, ...
    'meanRadius', meanR, ...
    'regressor', R, ...
    'predictions', P);

if sv
    nm = sprintf('%s_regression_%dSpots', datestr(now, 'yymmdd'), length(P));
    regressionData    = X; %#ok<NASGU>
    radiiRegressor    = R; %#ok<NASGU>
    radiusPredictions = P; %#ok<NASGU>
    save(nm, '-v7.3', 'regressionData', 'radiiRegressor', 'radiusPredictions');
end

end


