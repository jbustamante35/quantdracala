%% Plate: main class for individual 96-well plates of DRaCALA experiment
% Explanation of this class
%
%

classdef Plate < handle
    properties (Access = public)
        %% Main data and properties
        BoardSetName
        BoardSetPath
        BoardName
        PlateName
        NumSpots
    end
    
    properties (Access = private)
        %% Private data properties
        Spots
        BoardCoordinates
        PlateImage
        gray
        bw
        PlateData
        RADIIRANGE = [12 28]
        CROPBUFFER = 4
    end
    
    methods (Access = public)
        %% Constructor and primary methods
        function obj = Plate(varargin)
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
                obj.PlateName = '';
            end
            
            obj.PlateImage = struct('gray', obj.gray, ...
                'bw', obj.bw);
        end
        
        function obj = FindSpots(obj)
            %% Search Plate for Spot objects
            % Method to perform Hough Circle Transform on Plate to identify Spot objects
            % Crop out Spot and store raw and rescaled image and properties
            im  = obj.getPlateImage('gray');
            msk = obj.getPlateImage('bw');
            
            % Extract and Crop all circular objects in Plate image
            circs = extractCircles(obj, im, obj.RADIIRANGE);
            crops = arrayfun(@(x, y, z) obj.cropWithBuffer(im, [x y], z, obj.CROPBUFFER),...
                circs.Centers(:,1), circs.Centers(:,2), ...
                circs.Radii, 'UniformOutput', 0);
            
            masks = arrayfun(@(x, y, z) obj.cropWithBuffer(msk, [x y], z, obj.CROPBUFFER),...
                circs.Centers(:,1), circs.Centers(:,2), ...
                circs.Radii, 'UniformOutput', 0);
            
            % Create Spot object for each cropped image
            for sp = 1 : numel(crops)
                nm = sprintf('Spot_%d', sp);
                obj.Spots(sp) = Spot(nm, ...
                    'gray',             crops{sp}, ...
                    'bw',               masks{sp}, ...
                    'PlateCoordinates', circs.Centers(sp,:), ...
                    'RawRadius',        circs.Radii(sp), ...
                    'BoardSetName',     obj.BoardSetName, ...
                    'BoardSetPath',     obj.BoardSetPath, ...
                    'BoardName',        obj.BoardName, ...
                    'PlateName',        obj.PlateName);
            end
            
            obj.NumSpots = numel(obj.Spots);
        end
        
    end
    
    methods (Access = public)
        %% Accessible helper functions
        function obj = setName(n)
            %% Set name of this Board
            try
                obj.PlateName = n;
            catch
                fprintf(2, 'Name must be type string\n');
            end
            
        end
        
        function n = getName(obj)
            %% Returns name of this Board
            try
                n = obj.PlateName;
            catch
                fprintf(2, 'Error accessing Plate name\n');
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
            %% Returns name of Board parent
            try
                bn = obj.BoardName;
            catch
                fprintf(2, 'Error accessing Board name\n');
            end
        end
                    
        function dat = getPlateImage(varargin)
            %% Return grayscale or bw image of Plate object
            % User can specify which image from structure with 3rd parameter
            switch nargin
                case 1
                    % Full structure of image data at all frames 
                    obj = varargin{1};
                    dat = obj.PlateImage;
                    
                case 2
                    % Specify 'gray' or 'bw' image               
                    % Get requested data field 
                    try
                        obj = varargin{1};
                        req = varargin{2};                    
                        dfm = obj.PlateImage;
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
        
        function crds = getCoordinates(obj)
            %% Returns coordinates of Plate on parent Board
            crds = obj.BoardCoordinates;
        end
        
        function pd = getPlateData(obj, dtype)
            %% Return miscelleneous data describing this Plate
            % dtype is case-insensitive string describing what data to return
            try
                if strcmpi(dtype, 'all')
                    pd = obj.PlateData;
                else
                    fn = fieldnames(obj.PlateData);
                    fd = strcmpi(fn, dtype);
                    pd = obj.PlateData.(fn{fd});
                end
            catch
                fprintf('Data type ''%s'' not found \n', dtype);
            end
        end
        
        function sp = getSpot(obj, num)
            %% Returns Spot at desired index
            try
                sp = obj.Spots(num);
            catch
                fprintf(2,  'No Spot at index %d \n', num);
            end
        end
        
    end
    
    methods (Access = private)
        %% Private methods
        function args = parseConstructorInput(varargin)
            %% Parse input parameters for Constructor method
            p = inputParser;
            p.addRequired('PlateName');
            p.addOptional('BoardSetName', '');
            p.addOptional('BoardSetPath', '');
            p.addOptional('BoardName', '');
            p.addOptional('Spots', Spot);
            p.addOptional('PlateImage', struct());
            p.addOptional('gray', []);
            p.addOptional('bw', []);
            p.addOptional('PlateData', struct());
            p.addOptional('NumSpots', 0);
            p.addOptional('BoardCoordinates', []);
            
            % Parse arguments and output into structure
            p.parse(varargin{2}{:});
            args = p.Results;
        end
        
        function circs = extractCircles(obj, im, rng)
            %% Extract centroids from all circle objects found in image
            % I messed around with a lot of different methods and parameter values here, but only on
            % a single image. Keep adjusting these for when I do larger analyses.
            % Get logical matrix using 'canny' method with threshold of 0.06
            % Use Hough Circle Transform to identify circular objects in image
            % Output structure containing center coordinates and radii sizes
            edg        = edge(im, 'canny', 0.06);
            [cen, rad] = imfindcircles(edg, rng, 'Method', 'PhaseCode', 'Sensitivity', 0.9);
            circs      = struct('Centers', cen, 'Radii', rad);
        end
        
        function crp = cropWithBuffer(obj, im, cen, rad, buff)
            %% Crop given image from centroid position out to radius distance with a buffer
            % Calculate total size to crop image and bounding box position to begin cropping
            rectCrds(1:4) = 0;
            crpSz         = (rad * 2) + (buff * 2);
            rectCrds(1:2) = cen - (rad + buff);
            rectCrds(3:4) = [crpSz crpSz];
            crp           = imcrop(im, rectCrds);
        end
        
    end
end