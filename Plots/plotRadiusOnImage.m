function plotRadiusOnImage(im, midOut, midIn, radOut, radIn)
%% Overlay inner and outer circles on image
% View inner and outer circle on inputted image of Spot
% 
% Usage:
%   plotRadiusOnImage(im, midOut, midIn, radOut, radIn)
% 
% Input:
%   im: image of Spot
%   midOut: midpoint of outer circle
%   midIn: midpoint of inner circle
%   radOut: radius of outer circle
%   radIn: radius of inner circle
%   

imagesc(im);
colormap gray, axis image;
hold on;

viscircles(midOut,radOut, 'Color', 'g');
viscircles(midIn, radIn, 'Color', 'r');

hold off;
end