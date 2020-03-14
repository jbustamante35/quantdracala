function [p, d] = getDirName(n)
%% getDirName: function to parse folder name from current path
% This function takes in the path to a directory or file, and splits them
% into the name of that directory or file. Additionally, you can return the
% full path with the final directory or file name excluded.
% 
% Usage:
%   [p, d] = getDirName(n)
% 
% Input:
%   n: path string to directory or file
% 
% Output:
%   p: input n without full path string
%   d: path to directory of name_out
% 

    if isunix
        p = regexp(n, '\/', 'split');
        m = strfind(n, '/');
    else
        p = regexp(n, '\\', 'split');
        m = strfind(n, '\');
    end

    d = n(1 : m(end));
    p = p{end};

end