%% Arunima's starting script
%% load data
%FOVData = load('\\10.21.17.86\s\Images\Haixin\SPOTLight\20230922\CLM\FOVData.mat');
%CalibrationInfo = load('\\10.21.17.86\s\Images\Haixin\SPOTLight\20230922\CLM\CalibrationInfo.mat');
FOVData = load('/Users/nima/Desktop/Baylor Data/FOVData.mat'); 
CalibrationInfo = load('/Users/nima/Desktop/Baylor Data/CalibrationInfo.mat'); 
%% 
iImage = 2;
FOVImage = FOVData.FOVImage{iImage};
figure;
imagesc(FOVImage);
title('Take a look the image of this FOV')
%% 
[FOVPixelSizeY, FOVPixelSizeX] = size(FOVImage); 
FOVPhysicalSizeX = FOVPixelSizeX* CalibrationInfo.Resolution/1000; % CalibrationInfo.Resolution is um/pixel, physical size is in mm as defined in plate
FOVPhysicalSizeY = FOVPixelSizeY * CalibrationInfo.Resolution/1000;

FOVStageCoor = FOVData.FOVStagePosition{iImage}; % CAUTION: this is in um

%% Let make a 24well plate
% we will use our composite data structure classes: library, protocol, plate, well,
% fov
% Planner helps arrange the plate 
experimentFolder = '.';
plateID = 1;
protocol = spcore.Protocol('Name', 'Test', ...
    'Path', experimentFolder);

plate = spcore.Plate.getDefault('PlateType', 'P24-1.5H-N', ...
    'scope', 'S636E Okolab', ...
    'ID', plateID);

protocol.setPlate(plate);
library = spcore.Library('Protocol', protocol);
planner = spcore.hardware.Planner(library);
group = planner.addGroup();

disp('Finished initialize protocol and plate');
%% let make a well A2
wellName = {'A2'};
planner.addWell('Group', 1, ...
    'Plate', plateID, ...
    'WellName', wellName);
currWell = planner.getWell('WellName', wellName, 'Plate', plateID);
planner.addFOV('Well', currWell, ...
    'XRelativePosition', 0, ...
    'YRelativePosition', 0, ...
    'XPhysicalSize', FOVPhysicalSizeX, ...
    'YPhysicalSize', FOVPhysicalSizeY);
% FOV added to the center

n = navigator(); n.load(library); % load library to show
%% Task for Arunima:


%1. place the image to the FOV added to navigator

    % Creates a channel for a monochromatic image displaying in bue. 
      monoChannel = spcore.ui.navigator.Channel('Name', 'Image', ..._ 
                                                'Color', 'blue', ...
                                                'CLim', [0 (2e16)-1], ...
                                                'CRange', [0, (2e16)-1]); 
    plateScale = [sign(0.5 - plate.XReverse), -sign(0.5 - plate.YReverse)];
    T = spcore.ui.navigator.Image.getTransformation(...
    'Scale', plateScale .* [1, 1], ...
    'Translate', [FOVStageCoor.X FOVStageCoor.Y]);

    % Adds the custom image onto the plate
    mMono = monoChannel.addImage(...
    'CData', FOVImage, ...
    'Transformation', T);

    % Updates the navigator. 
    n.addChannel('Channel', monoChannel);
    %n.CurrentObject = w;
    %n.zoomFit('selected'); % Zooms onto plate with the image.
%{ 
2. from the data, this FOV has a stage coordinate (center of FOV) as in
'FOVStageCoor'. Can you figure out which well does this FOV belong to? if
so, can you generate the right well and FOV, and place the image there?
3. chanllenging question: can you rotate the FOV? (this requires reading
the actual code of planner's addFOV method and chase down the chain to see
if you can tilt the FOV in any way. )

%}


