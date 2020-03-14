function [pX, vX, tX] = pcaPrep(D, pct)
%% pcaPrep: exract subsets of rasterized datasets to prepare for PCA
% This function takes in a full rasterized data set and randomly sorts out sets for pca analysis,
% validation sets, and a testing set. User defines the size of the pca set, while validation and
% testing sets are split among the remaining data.
%
% Usage:
%   [pX, vX, tX] = pcaPrep(sX, setPct)
%
% Input:
%   D: [n x m x d] matrix of d ovservations of [n x m] images; can also be inputted as a
%      [d x 1] cell array, but this is immediatedly converted to the former structure
%   setPct: percentage of m observations to use for PCA
%
% Output:
%   pX: rasterized subset to use for PCA, size defined be setPct
%   vX: rasterized subset to use for validation
%   tX: rasterized subset to use for testing
%
% Prepare data matrices

if iscell(D)
    D = cat(3, D{:});
end

% PCA Set
pcaObs  = size(D,3);
pcaSize = ceil(pct * pcaObs);
pcaIdx  = randperm(pcaObs, pcaSize);
pcaSet  = D(:, :, pcaIdx);
[pX, ~] = rasterizeImagesQD(pcaSet);

% Set aside Validation Set
valX    = D(:, :, ~ismember(1:pcaObs, pcaIdx));
valObs  = size(valX,3);
valSize = ceil(valObs / 2);
valIdx  = randperm(valObs, valSize);
valSet  = valX(:, :, valIdx);
[vX, ~] = rasterizeImagesQD(valSet);

% Set aside Testing Set
tstX    = valX(:, :, ~ismember(1:valObs, valIdx));
[tX, ~] = rasterizeImagesQD(tstX);

end