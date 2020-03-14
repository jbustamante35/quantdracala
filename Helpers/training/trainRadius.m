function [D, C] = trainRadius(I, sv, vis)
%% trainRadius: train radius predictions by setting user-defined radii on training set
%
%
% Usage:
%   [D,C] = trainRadius(I, sv, vis)
%
% Input:
%   I: [m x n x t] vectorized input dataset
%   sv: save results in .mat file
%   vis: show figures highlighting training results
%
% Output:
%   D: user-defined radii from training set
%   C: position and midpoint coordinates of corresponding D
%

%% Set user-defined radius around each Spot of training set
N          = size(I,3);
D          = zeros(N, 2);
[Cout,Cin] = deal(struct('Position', zeros(1,4), 'Center', zeros(1,2)));

for t = 1 : N
    % Set circle
    imagesc(I(:,:,t));
    colormap gray, axis image;
    ttl = sprintf('Set Outer Radius (%d)', t);
    fprintf('%s \n', ttl);
    title(ttl);
    [D(t,1), Cout(t)] = getUserRadius('g');
    
    ttl = sprintf('Set Inner Radius (%d)', t);
    fprintf('%s \n', ttl);
    title(ttl);
    [D(t,2), Cin(t)] = getUserRadius('r');
end

C = struct('Outer', Cout, 'Inner', Cin);
%% Save results
if sv
    nm = sprintf('%s_trainingData_%dSpots', datestr(now,'yymmdd'), N);
    trainingData = D; %#ok<NASGU>
    circles      = C; %#ok<NASGU>
    save(nm, '-v7.3', 'trainingData', 'circles');
end

%% Show samples of circles on Spots
if vis
    fig = figure;
    set(fig, 'color', 'w');
    try
        rnd = randperm(N, 9);
    catch
        rnd = randperm(N,N);
    end
    row = 3;
    col = round(numel(rnd) / row);
    j   = 1;
    
    for k = rnd
        subplot(row, col, j);
        cout = Cout(k).Center;
        cin = Cin(k).Center;
%         plotRadiusOnImage(I(:,:,k), C(k,:,1), C(k,:,2), D(k,1), D(k,2));
        plotRadiusOnImage(I(:,:,k), cout, cin, D(k,1), D(k,2));
        j = j + 1;
    end
    
end
end

function [dst, dat] = getUserRadius(colr)
%% Set circle and obtain mean distance from center
c = imellipse;
c.setColor(colr);
pause;

% Get mean distance from center
crd = c.getVertices;
mid = mean(crd);
pos = c.getPosition;
dst = mean(pdist2(crd, mid));

dat = struct('Position', pos, ...
    'Center', mid);
c.delete;
end
