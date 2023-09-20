% Arunima Jaiswal 
% 9/20/23 Training Project 

% Creates a function to display a custom image in the Navigator. 
function NavigatorImageDisp
    % Creates a new navigator with 24 plates. 
    n = navigator();
    plate = spcore.Plate.getDefault('PlateType', 'P24-1.5H-N'); 
    n.new(plate); 
    w = n.RootObject.getChildren('w', 1); 
    % Creates a channel for a monochromatic image displaying in white. 
    monoChannel = spcore.ui.navigator.Channel('Name', 'Image', ..._ 
        'Color', 'white', ...
        'CLim', [0 255], ...
        'CRange', [0, 255]); 
    % Scales the plate and transforms the image to fit properly. 
    plateScale = [sign(0.5 - plate.XReverse), -sign(0.5 - plate.YReverse)];
    T = spcore.ui.navigator.Image.getTransformation(...
    'Scale', plateScale.*[19, 19], ...
    'Translate', [w.XPosition, w.YPosition + 1]);
    % Adds the custom image onto the plate (MATLAB default image used) 
    mMono = monoChannel.addImage(...
    'CData', imread('mri.tif'), ...
    'Transformation', T);
    % Updates the navigator.  
    n.addChannel('Channel', monoChannel);
    n.CurrentObject = w;
    %n.zoomFit('selected'); % Zooms onto plate with the image. 

