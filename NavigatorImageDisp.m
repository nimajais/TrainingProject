% Arunima Jaiswal 
% 9/20/23 Training Project 

% Creates a function to display a custom image in the Navigator. 
function NavigatorImageDisp(xpos, ypos)
    % Creates a new navigator with 24 plates. 
    n = navigator();
    n.DarkMode = false;
    plate = spcore.Plate.getDefault('PlateType', 'P24-1.5H-N'); 
    n.new(plate); 
    % Provides the image info for the sample image. 
    imgarray = imfinfo('forest.tif'); 
    disp(imgarray(1)) 
    % Asks the user for which well they'd like ot use to display their
    % image, and displays it in that well accordingly. 
    wellprompt = "Which well (1-24) would you like to display your image in?"; 
    wellnumber = input(wellprompt); 
    w = n.RootObject.getChildren('w', wellnumber); 
    % Creates a channel for a monochromatic image displaying in white. 
    monoChannel = spcore.ui.navigator.Channel('Name', 'Image', ..._ 
        'Color', 'white', ...
        'CLim', [0 255], ...
        'CRange', [0, 255]); 
    % Scales the plate and transforms the image to fit properly. 
    plateScale = [sign(0.5 - plate.XReverse), -sign(0.5 - plate.YReverse)];
    % Scales the image to fit in the well according to their given width
    % and height of the image. 
    xscaleprompt = "What is the width of your image?"; 
    xscale = input(xscaleprompt); 
    yscaleprompt = "What is the height of your image?"; 
    yscale = input(yscaleprompt); 
    yscale = 2432 / (sqrt((0.5*xscale^2)+(0.5*yscale^2)));   
    xscale = yscale;  
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

