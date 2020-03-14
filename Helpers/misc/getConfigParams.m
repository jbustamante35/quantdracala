function params = getConfigParams(config_type, config_file)
%% getConfigParams: extract configuration parameters for converting inf2img or ql2psl
% Retrieve main parameters used for conversion methods
%
% Usage: 
%   params = getConfigParams(config_type, config_file)
% 
% Input:
%   config_type: 'inf2img' or 'ql2psl'
%   config_setting: path to custom config file or 'default'
%                   using custom file not available yet
%
% Output:
%   f: structure containing parameters to use for conversion methods
%

switch config_type
    case 'inf2img'
        if config_file == 'default'
            config_file = which('inf2img.conf');
            params      = loadConfigFile(config_file);
        else
            fprintf(2, 'custom configuration file in %s not supported yet\n', config_file);
            return;
        end
        
    case 'ql2psl'
        if config_file == 'default'
            config_file = which('ql2psl.conf');
            params      = loadConfigFile(config_file);
        else
            fprintf(2, 'custom configuration file in %s not supported yet\n', config_file);
            return;
        end
        
    otherwise
        fprintf(2, 'config_type %s not found.\n', config_type);
        return;
end

end