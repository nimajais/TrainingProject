% Arunima Jaiswal 
% 9/20/23 Training Project 
% Creates a function to display a custom image in the Navigator. 
function NavigatorImageDisp(~, ~, ~, ~)
    xpos = 0; 
    ypos = 0;  
    xsize = 0.5;  
    ysize = 0.5; 
    
    % Creates a new navigator with 24 plates. 
    protocol = spcore.Protocol('Name', 'Test experiment', ...
    'Path', 'D:\');
    plate = spcore.Plate.getDefault('PlateType', 'P24-1.5H-N');     
    protocol.setPlate(plate);
    lib = spcore.Library('Protocol', protocol);
    p = spcore.hardware.Planner(lib);
    g = p.addGroup();

    
    protocol = spcore.Protocol('Name', 'Image Disp Test', ...
    'Path', 'D:\');
    lib = spcore.Library('Protocol', protocol); 
    p = spcore.hardware.Planner(lib); 
    g = p.addGroup();
    disp(lib.Count) 
    % Set wells
    p.addWell('Group', 1, ...
              'Plate', 1, ...
              'WellName', 'A1-D8', ...
              'Name', 'test');
    % Set FOV
    p.addTiledFOV('Well', lib.getChildren('well'), ...
                  'RowCount', 4, ...
                  'ColumnCount', 3, ...
                  'XPhysicalSize', xsize, ...
                  'YPhysicalSize', ysize, ...
                  'ColumnSeparation', 1, ...
                  'RowSeparation', 1);
    % simulated view
    fg = FOVGenerator('Plate', plate, ...
                      'XPhysicalSize', xsize, ...
                      'YPhysicalSize', ysize, ...
                      'Resolution', 0.32, ...
                      'Density', 1000);
    
    % Provides the image info for the sample image. 
    imgarray = imfinfo('mri.tif'); 
    disp(imgarray(1)) 
    % Creates a channel for a monochromatic image displaying in white. 
    monoChannel = spcore.ui.navigator.Channel('Name', 'Image', ..._ 
        'Color', 'white', ...
        'CLim', [0 255], ...
        'CRange', [0, 255]); 
    % Scales the plate and transforms the image to fit properly. 
    plateScale = [sign(0.5 - plate.XReverse), -sign(0.5 - plate.YReverse)];
    % Vertically and horizontally moves the image according to its position
    % in the well. 
    xpos = w.XPosition - xpos; 
    ypos = w.YPosition - ypos; 
    %disp(w.XPosition + ", " + w.YPosition 
    T = spcore.ui.navigator.Image.getTransformation(...
    'Scale', plateScale .* [xscale, yscale], ...
    'Translate', [xpos, ypos]);
    % Adds the custom image onto the plate (MATLAB default image used) 
    mMono = monoChannel.addImage(...
    'CData', imread('forest.tif'), ...
    'Transformation', T);
    % Updates the navigator. 
    n.addChannel('Channel', monoChannel);
    n.CurrentObject = w;
    n.zoomFit('selected'); % Zooms onto plate with the image.
    

