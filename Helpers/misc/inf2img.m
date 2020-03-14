function im = inf2img(infpth, imgpth, prm, fmt, infprc, delim, imgprc, angl)
%% inf2img: converts binary .img file to image using parameters from corresponding .inf file
% This function reads parameters from a .inf file and uses them to convert a binary .img image into
% a usable image file. Outputted image has QL-pixel intensities
%
% Usage:
%   im = inf2img(infpth, imgpth, prm, fmt, infprc, delim, imgprc, angl)
%
% Input:
%   infpth: path to .inf file
%   imgpth: path to .img image
%   prm: permissions for opening file
%   fmt: machine format
%   infprc: encoding precision for reading .inf file
%   delim: delimiter for making cell string array
%   imgprc: encoding precision for .img file
%   angl: angle to rotate final outputted image
%
% Output:
%   im: outputted image from .img file in QL-pixel intensities
%
%% For Debug Purposes: Test with default parameter values
% Comment out for regular use! 
% permission = 'r';        % Open files with Read-only permissions
% machinefmt = 's';        % Read .img with 64-bit long, big-endian ordering
% precision_inf = '*char'; % Read .inf with char encoding
% delimiter_inf = '\n';    % Set .inf delimiter to make cell string array
% precision_img = 'ubit16';% Read .img with binary 16-bit encoding
% angle = -90;             % Rotate .img image 90� counter-clockwise

%% Open, Read, and Extract information from .inf file
finf = fopen(infpth, prm);
rinf = fread(finf, [1 Inf], infprc);
fstr = strsplit(rinf, delim);

% Store information into structure array
fn   = {'ImageFile', 'iDunno', 'Sen' 'Bits', 'Rows', 'Columns', 'Res', 'Lat'};
dinf = fstr(1, 2:9)';
INF = cell2struct(dinf, fn);
fclose(finf);

%% Open .img file and read image using parameters from .inf file
% Flip and Rotate raw image, since output is in an oddly flipped orientation
% Set-up parameters for reading .img file and converting to PSL-pixels
sz   = [str2double(INF.Rows) str2double(INF.Columns)]; % size to reshape image 
fimg = fopen(imgpth, prm, fmt);
im   = fliplr(imrotate(fread(fimg, sz, imgprc), angl));
fclose(fimg);

end