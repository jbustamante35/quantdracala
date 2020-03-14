function [QD, bs] = TestQuantDRaCALA(numC, maxPCA, scaleSize, setPct, trnSize, DataSet, sv, vis)
%% TestQuantDRaCALA: main program to testrun QuantDRaCALA analysis
% This function performs a test run of QuantDRaCALA, where the user can either create a new dataset
% from the SampleData folder or reuse an already-prepped BoardSet (DataSet parameter). This pipeline
% extracts all Spots from all Plates in each Board of the inputted BoardSet, runs PCA with the
% number of PCs defined in numC, then sets aside observations for validation and testing sets. The
% proportion of data to use for PCA is defined by setPct, while 1 - setPct is split for validation
% and testing. After PCA, the trnSize parameter defines the size of data to use for training. The
% user can save outputs with the boolean sv parameter, or visualize output with the vis paremeter.
%
% Usage:
%   [QD, bs] = TestQuantDRaCALA(numC, maxPCA, scaleSize, setPct, trnSize, DataSet, sv, vis)
%
% Input:
%   numC: number of principal components (PCs) for PCA
%   maxPCA: largest number of PCs to run through PCA (to test best number for numC)
%   scaleSize: original size of individual observations for reshape function
%   setPct: proportion of full dataset to use for PCA; remainder is split between validation/testing
%   trnSize: number of observations after PCA to use for manually training radius sizes
%   DataSet: can be a boolean value to create a new set, or a BoardSet previously created
%   sv: boolean to save final output into .mat files
%   vis: visualize random set of 5 synthetically recreated Spots across all maxPCA PCs
%
% Output:
%   QD: structure containing raw PCA input, analyzed PCA output, and training/validation/testing sets
%   bs: BoardSet object used for this analysis
%

%% Begin analysis with new BoardSet or previously-created BoardSet
if ~strcmpi(class(DataSet), 'BoardSet')
    %% Load new dataset from SampleData
    if DataSet
        % Find path to SampleData directory
        qd_dir = which('TestQuantDRaCALA');
        [~, y] = getDirName(qd_dir);
        pth    = [y 'SampleData'];
        
        % Set up BoardSet object 
        bnm = getDirName(pth);
        bs  = BoardSet(bnm, 'BoardSetPath', pth);
        bs.LoadBoards;
    end
    
    %% Extract individual Plate objects from each Board
    sX = {};
    j = 1;
    for i = 1 : bs.NumBoards
        b = bs.getBoard(i);
        b.LoadPlates;
        for ii = 1 : b.NumPlates
            p = b.getPlate(ii);
            p.FindSpots;
            plts = cat(1, b.getPlate(':').NumSpots);
            fprintf('Board %d | Plate %d | Spots: %s \n', i, ii, num2str(plts'));
            for iii = 1 : p.NumSpots
                s = p.getSpot(iii);
                s.NormalizeSpot;
                sX{j} = s.getNormImage('gray');
                j = j + 1;
            end
        end
    end
    
    % Check number of plates from each board
    plts = cat(1,  bs.getBoard(':').NumPlates);
    fprintf('Plates per Board\n %s \n', num2str(plts'));
    
else
    %% Use previously-loaded data and just extract all Spots and Spot images
    bs = DataSet;
    b  = bs.getBoard(':');
    p  = arrayfun(@(x) x.getPlate(':'), b, 'UniformOutput', 0);
    p  = cat(1, p{:});
    s  = arrayfun(@(x) x.getSpot(':'), p, 'UniformOutput', 0);
    s  = cat(1, s{:});
    sX = arrayfun(@(x) x.getNormImage('gray'), s, 'UniformOutput', 0);
end

%% Perform Principal Components Analysis
% Prepare PCA, validation, and testing dataset and perform PCA with number of PCs defined in numC
[pcaX, valX, tstX] = pcaPrep(sX, setPct);
[pcaC, pcaB]       = pcaAnalysis(pcaX, numC, scaleSize, 0, 'QD_spots', 0);

pcaData = struct('custom', pcaC, ...
    'builtin', pcaB);

%% Make subsets of Spots for Training, Validation, and Testing based on PCAscore proportions
% Training Set
ppt     = [0.3 0.4 0.3];
scrs    = pcaC.PCAscores;
trnIdx  = getSubset(scrs, trnSize, 1, ppt);
trnScrs = scrs(trnIdx,:);
shpX    = reshape(pcaX(trnIdx,:), [trnSize scaleSize]);
trnX    = permute(shpX, [2 3 1]);

% Validation Set
valRem = scrs(~ismember(1:length(scrs), trnIdx), :);
if trnSize > length(valRem)
    valSize = round(length(valRem) / 2);
else
    valSize = trnSize;
end
valIdx  = getSubset(valRem, valSize, 1, ppt);
valScrs = valRem(valIdx,:);

% Testing Set
tstRem = scrs(~ismember(scrs(:,1), [valRem(valIdx) scrs(trnIdx)]),:);
if trnSize > length(tstRem)
    tstSize = round(length(tstRem) / 2);
else
    tstSize = trnSize;
end
tstIdx  = getSubset(tstRem, tstSize, 1, ppt);
tstScrs = tstRem(tstIdx,:);

subsets = struct('training', trnScrs, ...
    'validation', valScrs, ...
    'testing', tstScrs);

rastData = struct('pcaX', pcaX, ...
    'trnX', trnX, ...
    'valX', valX, ...
    'tstX', tstX);

%% Output final combined data
QD = struct('raster', rastData, ...
    'pca', pcaData, ...
    'scores', subsets);

if sv
    pnm = sprintf('%s_pcaQD_%dSpots_%dPCs', datestr(now, 'yymmdd'), length(scrs), numC);
    save(pnm, '-v7.3', 'QD');
    
    bnm = sprintf('%s_QDset_%s', datestr(now, 'yymmdd'), bs.getName);
    save(bnm, '-v7.3', 'bs');
end

%% View all Spots
if vis
    %     % All Boards in BoardSet
    %     figure;
    %     viewAll(bs);
    
    % View 5 Random Spot across all PCs
    pC  = @(x) pcaAnalysis(pcaX, x, scaleSize, 0, 'spotsQD', 0);
    rng = 1 : maxPCA;
    chk = cell(1,maxPCA);
    for r = rng
        chk{r} = pC(r);
        fprintf('Running PCA with %d Principal Components\n', r);
    end
    
    for i = 1 : 5
        curr = figure;
        set(gcf,'color','w');
        comparePCs(chk, maxPCA, scaleSize);
        
        if sv
            fignm = sprintf('%s_pcaQD_comparePCs_%dPCs', datestr(now, 'yymmdd'), i);
            savefig(curr, fignm);
            saveas(curr, fignm, 'tiffn');
        end
    end
end

end

function sub = getSubset(scrs, sz, dim, ppt)
%% Extract a subset of Spots with given distributions for low-rand-high PCA scores
[~, idx] = sortrows(scrs, dim);
low  = ppt(1);
rnd  = ppt(2);
high = ppt(3);

% Total sizes for each subset [reduce sz if length of input < requested size of output
if sz > length(scrs)
    sz = length(scrs);
end

szL = round(low * sz);
szH = round(high * sz);
szR = round(rnd * sz);

% Sort and index low and high subsets
idxL = idx(1:szL);
idxH = idx(end - szH + 1 : end);

% Get random subset from remaining indices
rmn  = idx(szL+1 : (end - szH));
rIdx = randperm(numel(rmn), szR);
idxR = rmn(rIdx);

% Final set contains indices of PCAscores representating each subset
sub = [idxL ; idxR ; idxH];

end

function comparePCs(pcaChk, maxpc, sz)
%% View original and synthetic random Spot across all PCs
r    = randi(size(pcaChk{1}.InputData, 1), 1);
rows = round(maxpc / 2) + 1;
cols = 2;

for n = 1 : maxpc
    curr = pcaChk{n};
    
    % Original image
    org = reshape(curr.InputData(r,:), sz);
    subplot(rows, cols, 1);
    imagesc(org);
    colormap gray, axis image;
    title(sprintf('Spot %d (original)', r));
    
    % Simulated image
    im   = reshape(curr.SimData(r,:), sz);
    subplot(rows, cols, n+2);
    imagesc(im);
    colormap gray, axis image;
    title(sprintf('Spot %d (%d PCs)', r, n));
    
    drawnow;
end

end

function viewAll(brdset)
%% View all Spots from all Plates from all Boards from inputted BoardSet
for i = 1 : brdset.NumBoards
    bd = brdset.getBoard(i);
    for ii = 1 : bd.NumPlates
        pl = bd.getPlate(ii);
        for iii = 1 : pl.NumSpots
            sp = pl.getSpot(iii);
            imagesc(sp.getNormImage('gray'));
            ttl = sprintf('Board %d | Plate %d | Spot %d', i, ii, iii);
            title(ttl);
            colormap gray, axis image;
            drawnow;
        end
    end
end
end