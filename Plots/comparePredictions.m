function comparePredictions(D, P, sv)
%% comparePredictions: plot user-defined and predicted data for outer and inner radii
% 
% 
% Usage:
%   comparePredictions(D, P, sv)
% 
% Input:
%   D: user-defined data
%   P: output of predicted data from calculateRegression function
%   sv: save output as .fig and uncompressed .tif figures 
%   
% Output: n/a
% 
% 

fig = figure;
set(gcf, 'Color', 'w');

subplot(221);
linePlot(D(:,1), P(:,1), 'Outer');

subplot(222);
scatterPlot(D(:,1), P(:,1), 'Outer');

subplot(223);
linePlot(D(:,2), P(:,2), 'Inner');

subplot(224);
scatterPlot(D(:,2), P(:,2), 'Inner');

% Save figures as .fig and uncompressed .tif 
if sv
    nm = sprintf('%s_trainingComparisons', datestr(now,'yymmdd'));
    savefig(fig, nm);
    saveas(fig, nm, 'tiffn');
end

end

function linePlot(d, p, r)
plot(d, 'r-');
hold on;
plot(p, 'g-');
legend('User-Defined', 'Predicted');
xlabel('Spot Index', 'FontWeight', 'bold', 'FontSize', 14);
ylabel(sprintf('%s Circle Radius (pix)', r), 'FontWeight', 'bold', 'FontSize', 14);
title(sprintf('%s Radius Training', r));
ylim([0 25]);
end

function scatterPlot(d, p, r)
title(sprintf('User vs. Predicted: %s Radius', r));
plot(d, p, 'b.', 'MarkerSize', 4);
legend(sprintf('%s Radius Training', r));
xlabel('User-Defined Radius', 'FontWeight', 'bold', 'FontSize', 14);
ylabel('Predicted Radius', 'FontWeight', 'bold', 'FontSize', 14);
end


