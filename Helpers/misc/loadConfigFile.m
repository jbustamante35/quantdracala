function params = loadConfigFile(config_file)
%% loadConfigFile: set parameters for conversion using values in configuration file
% This function takes values from input file to set parameters for converting parameters in a .inf
% file to a binary image found in .img file
% 
% Usage:
%   params = loadConfigFile(config_file)
% 
% Input:
%   config_file: path to configuration file
% 
% Output:
%   params: structure containing parameters to use for conversion function 
% 
% 

% Store current directory and configuration file directory
params = struct();
currDir = pwd;

[confDir, ~, ~] = fileparts(config_file);
cd(confDir);

% Load file and extract parameter names and values
fid  = fopen(config_file);
fstr = strsplit(fread(fid, [1 inf], '*char'), '\n');
fclose(fid);

% Store name, value into output structure 
for p = fstr
    prm_val = strsplit(cell2mat(p), ',');
    Pname = prm_val{1}(~isspace(prm_val{1}));
    Pval  = prm_val{2}(~isspace(prm_val{2}));
    params.(Pname) = Pval;
end

% Return to original directory
cd(currDir);

