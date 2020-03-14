%% Board: main class for loading PhosphoImager plates used for raw DRaCALA images
% Explanation of this class
%
%

classdef Board < handle
    properties (Access = public)
        %% Main data and properties
        BoardSetName
        BoardSetPath
        BoardName
        NumPlates
    end
    
    properties (Access = private)
        %% Private data properties
        Plates
        PLATEESIZE = [10000 10000000];
        INF
        IMG
        imQL
        imPSL
        inf2img_config
        inf2img_file
        ql2psl_file
        ql2psl_config
    end
    
    methods (Access = public)
        %% Constructor and primary methods
        function obj = Board(varargin)
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
                obj.BoardSetName = '';
                obj.inf2img_file = 'default';
                obj.ql2psl_file  = 'default';
            end
            
            obj.inf2img_config = getConfigParams('inf2img', obj.inf2img_file);
            obj.ql2psl_config  = getConfigParams('ql2psl', obj.ql2psl_file);
        end
        
        function obj = LoadBoardImage(obj)
            %% Convert .img to QL image then convert to PSL image
            obj.convertIMGFromINF;
            obj.convertQL2PSL;
            
        end
        
        function obj = LoadPlates(obj)
            %% Extract Plate objects from full image
            [prps, crps, msks] = obj.extractPlates(obj.imPSL);
            j = 1;
            for i = 1 : numel(prps)
                pn            = sprintf('Plate_%d', i);
                obj.Plates(j) = Plate(pn, ...
                    'BoardSetName',     obj.BoardSetName, ...
                    'BoardSetPath',     obj.BoardSetPath, ...
                    'BoardName',        obj.BoardName, ...
                    'gray',             crps{i}, ...
                    'bw',               msks{i}, ...
                    'BoardCoordinates', prps(i).Centroid, ...
                    'PlateData',        prps(i));
                obj.NumPlates = j;
                j = j + 1;
            end
        end
        
    end
    
    methods (Access = public)
        %% Accessible helper functions
        function obj = setName(obj, n)
            %% Set name of this Board
            try
                obj.BoardName = n;
            catch
                fprintf(2, 'Name must be type string\n');
            end
        end
        
        function n = getName(obj)
            %% Returns name of this Board
            try
                n = obj.BoardName;
            catch
                fprintf(2, 'Error accessing Board name\n');
            end
        end
        
        function p = getPath(obj)
            %% Returns path to this Board's image files
            p = obj.BoardSetPath;
        end
        
        function im = getBoardImage(obj, typ)
            %% Returns specified ql or psl image
            switch typ
                case 'ql'
                    im = obj.imQL;
                    
                case 'psl'
                    im = obj.imPSL;
                    
                otherwise
                    im = [];
                    fprintf(2, 'No image type specified in %s \n', typ);
                    fprintf(2, 'Input should be ''ql'' or ''psl''\n');
                    return;
            end
        end
        
        function inf = getInfFile(obj)
            %% Returns .inf file associated with this Board
            inf = obj.INF;
        end
        
        function img = getImgFile(obj)
            %% Returns .img file associated with this Board
            img = obj.IMG;
        end
        
        function prms = getInfParams(obj)
            %% Returns parameters for inf2img conversion
            prms = obj.inf2img_config;
        end
        
        function prms = getQLParams(obj)
            %% Returns parameters for ql2psl conversion
            prms = obj.ql2psl_config;
        end
        
        function obj = convertQL2PSL(obj)
            %% Convert QL-based image to PSL-based image
            params = obj.getQLParams;
            obj.imPSL = ql2psl(obj.imQL, ...
                str2double(params.res), ...
                str2double(params.sen), ...
                str2double(params.lat), ...
                str2double(params.grad), ...
                params.ConversionDirection);
        end
        
        function obj = convertIMGFromINF(obj)
            %% Convert .img format to image using properties set in .inf file
            if isunix
                delim = '/';
            else
                delim = '\';
            end
            
            % Set up file paths and conversion parameters
            infpth = [obj.getPath delim obj.getInfFile];
            imgpth = [obj.getPath delim obj.getImgFile];
            params = obj.getInfParams;
            
            obj.imQL = inf2img(infpth, imgpth, ...
                params.permission, ...
                params.machinefmt, ...
                params.precision_inf, ...
                params.delimiter_inf, ...
                params.precision_img, ...
                str2double(params.angle));
        end
        
        function plt = getPlate(obj, num)
            %% Return plate at desired index
            try
                plt = obj.Plates(num);
            catch
                plt = [];
                fprintf(2, 'No plate at index %d \n', num);
                return;
            end
        end
    end
    
    methods (Access = private)
        %% Private methods
        function args = parseConstructorInput(varargin)
            %% Parse input parameters for Constructor method
            p = inputParser;
            p.addRequired('BoardName');
            p.addOptional('BoardSetName', '');
            p.addOptional('BoardSetPath', '');
            p.addOptional('Plates', Plate);
            p.addOptional('NumPlates', 0)
            p.addOptional('imQL', []);
            p.addOptional('INF', []);
            p.addOptional('IMG', []);
            p.addOptional('inf2img_file', 'default');
            p.addOptional('ql2psl_file', 'default');
            p.addOptional('inf2img_config', struct());
            p.addOptional('ql2psl_config', struct());
            
            % Parse arguments and output into structure
            p.parse(varargin{2}{:});
            args = p.Results;
        end
        
        function [prps, crps, msks] = extractPlates(obj, im)
            %% Segment Board into indivindual Plate objects and return properties and cropped images
            % Segment and use min and max area thresholds to reduce number of objects found
            [dd, bw] = segmentObjectsQD(im, obj.PLATEESIZE);
            
            % Find objects in BW image
            p    = {'Area', 'BoundingBox', 'Centroid'};
            prps = regionprops(dd, im, p);
            crps = arrayfun(@(x) imcrop(im, x.BoundingBox), prps, 'UniformOutput', 0);
            msks = arrayfun(@(x) imcrop(bw, x.BoundingBox), prps, 'UniformOutput', 0);
        end
    end
    
    
    
end