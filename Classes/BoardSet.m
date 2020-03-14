%% BoardSet: class to hold a collection of Board objects for multiple QuantDRaCALA analyses
% Explanation of this class
%
%

classdef BoardSet < handle
    properties (Access = public)
        %% Main data and properties
        BoardSetName
        BoardSetPath
        NumBoards
    end
    
    properties (Access = private)
        %% Private data properties
        Boards
        INFs
        IMGs
    end
    
    methods (Access = public)
        %% Constructor and primary methods
        function obj = BoardSet(varargin)
            %% Constructor method to instance this object
            if ~isempty(varargin)
                % Parse inputs to set properties
                args = obj.parseConstructorInput(varargin);
                
                fn = fieldnames(args);
                for k = fn'
                    obj.(cell2mat(k)) = args.(cell2mat(k));
                end
                
            else
                % Set default properties for empty object
                obj.BoardSetName = getDirName(pwd);
                obj.BoardSetPath = pwd;
            end
            
            [obj.INFs, ~, ~] = obj.findFiles(obj.BoardSetPath, 'inf');
            [obj.IMGs, ~, ~] = obj.findFiles(obj.BoardSetPath, 'img');
            
        end
        
        function obj = LoadBoards(obj)
            %% Load Board objects from filenames in BoardSetPath
            j = 1;
            for f = obj.INFs'
                % Check for matching .inf/.img filenames
                f = char(f);
                if contains(f, obj.IMGs)
                    img = [f '.img'];
                    inf = [f '.inf'];
                    obj.Boards(j) = Board(f, ...
                        'BoardSetName', obj.getName, ...
                        'BoardSetPath', obj.BoardSetPath, ...
                        'IMG',          img, ...
                        'INF',          inf);
                    obj.Boards(j).LoadBoardImage;
                    obj.NumBoards = j;
                    j = j + 1;
                end
            end
            
        end
    end
    
    methods (Access = public)
        %% Accessible helper functions
        function obj = setName(n)
            %% Set name of this Board
            try
                obj.BoardSetName = n;
            catch
                fprintf(2, 'Name must be type string\n');
            end
            
        end
        
        function n = getName(obj)
            %% Returns name of this Board
            try
                n = obj.BoardSetName;
            catch
                fprintf(2, 'Error accessing BoardSet name\n');
            end
        end
        
        function obj = setPath(obj, p)
            %% Set path to this BoardSet
            try
                obj.BoardSetPath = p;
            catch
                fprintf(2, 'Name must be type string\n');
            end
        end
        
        function p = getPath(obj)
            %% Returns path to this BoardSet
            try
                p = obj.BoardSetPath;
            catch
                fprintf(2, 'Error accessing BoardSet name\n');
            end
        end
        
        function fn = getFilenames(obj, ftype)
            %% Returns names and paths of either .inf or .img files
            switch ftype
                case 'inf'
                    fn = obj.INFs;
                    
                case 'img'
                    fn = obj.IMGs;
                    
                otherwise
                    fn = [];
                    fprintf(2, 'Filetype must either be ''inf'' or ''img''\n');
                    return;
            end
        end
        
        function brd = getBoard(obj, num)
            %% Return Board object at desired index
            try
                brd = obj.Boards(num);
            catch
                fprintf(2, 'No Board at index %d \n', num);
                return;
            end
        end
        
    end
    
    methods (Access = private)
        %% Private methods
        function args = parseConstructorInput(varargin)
            %% Parse input parameters for Constructor method
            p = inputParser;
            p.addRequired('BoardSetName');
            p.addOptional('BoardSetPath', pwd);
            p.addOptional('Boards', Board);
            p.addOptional('NumBoards', 0);
            p.addOptional('INFs', []);
            p.addOptional('IMGs', []);
            
            p.parse(varargin{2}{:});
            args = p.Results;
        end
        
        function [fnames, fpaths, fexts] = findFiles(obj, din, ext)
            %% Extract desired filenames and filepaths in given directory
            currDir = pwd;
            cd(din);
            
            d = dir(['*.' ext]);
            
            if isunix
                delim = '/';
            else
                delim = '\';
            end
            
            fn = arrayfun(@(x) strcat(x.folder, delim, x.name), d, 'UniformOutput', 0);
            [fpaths, fnames, fexts] = cellfun(@(x) fileparts(x), fn, 'UniformOutput', 0);
            
            cd(currDir);
        end
    end
    
    
end
