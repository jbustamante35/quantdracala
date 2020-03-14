%% Spot: main class for a DRaCALA spot with inner and outer circles
% Explanation of this class
%
%

classdef Spot < handle
    properties (Access = public)
        %% Main data and properties
        BoardSetName
        BoardSetPath
        BoardName
        PlateName
        SpotName
    end
    
    properties (Access = private)
        %% Private data properties
        NORMSIZE = [51 51]
        SpotImage
        gray
        bw
        NormalSpot
        normgray
        normbw
        SpotData
        RawRadius
        SpotCoordinates
        PlateCoordinates
    end
    
    methods (Access = public)
        %% Constructor and primary methods
        function obj = Spot(varargin)
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
                obj.SpotName = '';
            end
            
            obj.SpotImage = struct('gray', obj.gray, ...
                'bw', obj.bw);
        end
        
        function obj = NormalizeSpot(obj)
            %% Rescale Spot to normalize all Spot objects
            obj.NormalSpot = struct('gray', obj.normgray, ...
                'bw', obj.normbw);
            
            im  = obj.getSpotImage('gray');
            msk = obj.getSpotImage('bw');
            obj.NormalSpot.gray = imresize(im, obj.NORMSIZE, 'triangle');
            obj.NormalSpot.bw   = imresize(msk, obj.NORMSIZE, 'triangle');
        end
    end
    
    methods (Access = public)
        %% Accessible helper functions
        function obj = setName(n)
            %% Set name of this Board
            try
                obj.SpotName = n;
            catch
                fprintf(2, 'Name must be type string\n');
            end
            
        end
        
        function n = getName(obj)
            %% Returns name of this Board
            try
                n = obj.SpotName;
            catch
                fprintf(2, 'Error accessing Spot name\n');
            end
        end
        
        function bs = getBoardSetName(obj)
            %% Returns name of BoardSet parent
            try
                bs = obj.BoardSetName;
            catch
                fprintf(2, 'Error accessing BoardSet name\n');
            end
        end
        
        function bp = getPath(obj)
            %% Return path from BoardSet parent
            bp = obj.BoardSetPath;
        end
        
        function bn = getBoardName(obj)
            %% Returns name of this Board
            try
                bn = obj.BoardName;
            catch
                fprintf(2, 'Error accessing Board name\n');
            end
        end
        
        function pn = getPlateName(obj)
            %% Returns name of this Board
            try
                pn = obj.PlateName;
            catch
                fprintf(2, 'Error accessing Plate name\n');
            end
        end
        
        function dat = getSpotImage(varargin)
            %% Return grayscale or bw image of Plate object
            % User can specify which image from structure with 3rd parameter
            switch nargin
                case 1
                    % Full structure of image data at all frames 
                    obj = varargin{1};
                    dat = obj.SpotImage;
                    
                case 2
                    % Specify 'gray' or 'bw' image               
                    % Get requested data field 
                    try
                        obj = varargin{1};
                        req = varargin{2};                    
                        dfm = obj.SpotImage;
                        dat = dfm.(req);                        
                    catch 
                        fn  = fieldnames(dfm);
                        str = sprintf('%s, ', fn{:});
                        fprintf(2, 'Requested field must be either: %s\n', str);
                    end                    
                    
                otherwise
                    fprintf(2, 'Error requesting data.\n');
                    return;
            end            
        end
        
        function nrm = getNormImage(varargin)
            %% Return grayscale or bw image of Plate object
            % User can specify which image from structure with 3rd parameter
            switch nargin
                case 1
                    % Full structure of image data at all frames 
                    obj = varargin{1};
                    nrm = obj.NormalSpot;
                    
                case 2
                    % Specify 'gray' or 'bw' image               
                    % Get requested data field 
                    obj = varargin{1};
                    dfm = obj.NormalSpot;
                    try                        
                        req = varargin{2};                                            
                        nrm = dfm.(req);                        
                    catch 
                        fn  = fieldnames(dfm);
                        str = sprintf('%s, ', fn{:});
                        fprintf(2, 'Requested field must be either: %s\n', str);
                    end                    
                    
                otherwise
                    fprintf(2, 'Error requesting data.\n');
                    return;
            end            
        end
        
        function sd = getSpotData(obj, dtype)
            %% Return data from Spot
            % dtype is case-insensitive string describing what data to return
            try
                if strcmpi(dtype, 'all')
                    sd = obj.SpotData;
                else
                    fn = fieldnames(obj.SpotData);
                    pd = strcmpi(fn, dtype);
                    sd = obj.SpotData.(fn{pd});
                end
            catch
                fprintf('Data type ''%s'' not found \n', dtype);
            end
        end
        
        function crds = getCoordinates(obj)
            %% Returns coordinates of Spot on parent Plate
            crds = obj.PlateCoordinates;
        end
        
    end
    
    methods (Access = private)
        %% Private methods
        function args = parseConstructorInput(varargin)
            %% Parse input parameters for Constructor method
            p = inputParser;
            p.addRequired('SpotName');
            p.addOptional('BoardSetName', '');
            p.addOptional('BoardSetPath', '');
            p.addOptional('BoardName', '');
            p.addOptional('PlateName', '');
            p.addOptional('SpotImage', struct());
            p.addOptional('gray', []);
            p.addOptional('bw', []);
            p.addOptional('SpotCoordinates', []);
            p.addOptional('NormalSpot', struct());
            p.addOptional('normgray', []);
            p.addOptional('normbw', []);
            p.addOptional('RawRadius', 0);
            p.addOptional('PlateCoordinates', []);
            
            % Parse arguments and output into structure
            p.parse(varargin{2}{:});
            args = p.Results;
        end
        
        
    end
    
    
end