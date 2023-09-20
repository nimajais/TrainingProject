% Arunima Jaiswal 
% 9/20/23 Training Project 

function NavigatorImageDisp
    n = navigator();
    plate = spcore.Plate.getDefault('PlateType', 'P24-1.5H-N'); 
    n.new(plate); 
    w = n.RootObject.getChildren('w', 1); 
    monoChannel = spcore.ui.navigator.Channel('Name', 'Image', ..._ 
        'Color', 'blue', ...
        'CLim', [0 255], ...
        'CRange', [0, 255]); 
    plateScale = [sign(0.5 - plate.XReverse), -sign(0.5 - plate.YReverse)];
    T = spcore.ui.navigator.Image.getTransformation(...
    'Scale', plateScale.*[2, 2], ...
    'Translate', [w.XPosition + 1.5, w.YPosition]);
    mMono = monoChannel.addImage(...
    'CData', imread('MicroscopeNeuron.tif'), ...
    'Transformation', T);
    n.addChannel('Channel', monoChannel);
    n.CurrentObject = w;
    n.zoomFit('selected');

