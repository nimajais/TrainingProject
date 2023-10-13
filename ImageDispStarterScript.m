%% Arunima's starting script
%% load data
%FOVData = load('\\10.21.17.86\s\Images\Haixin\SPOTLight\20230922\CLM\FOVData.mat');
%CalibrationInfo = load('\\10.21.17.86\s\Images\Haixin\SPOTLight\20230922\CLM\CalibrationInfo.mat');
FOVData = load('/Users/nima/Desktop/Baylor Data/FOVData.mat'); 
CalibrationInfo = load('/Users/nima/Desktop/Baylor Data/CalibrationInfo.mat'); 
%% Selects image to import into FOV 
iImage = 2;
FOVImage = FOVData.FOVImage{iImage};
%figure;
%imagesc(FOVImage);
%title('Take a look the image of this FOV')
%% Obtain stage coordinates and physical dimensions of FOV 
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
%% Create all of the wells in a 24 well plate.
%2. From the data, this FOV has a stage coordinate (center of FOV) as in
%'FOVStageCoor'. Can you figure out which well does this FOV belong to? if
%so, can you generate the right well and FOV, and place the image there? 
wellName = {'A1-D6'};
planner.addWell('Group', 1, ...
    'Plate', plateID, ...
    'WellName', wellName)

% Method 2: use wellName, isInside to check which well an FOV is in 
[wellname, isInside] = plate.xy2wellname(FOVStageCoor.X, FOVStageCoor.Y); 
    
% Adds FOV to the selected well in Navigator. 
FOVWell = planner.getWell('WellName', wellname, 'Plate', plateID); 
planner.addFOV('Well', FOVWell, ...
    'XRelativePosition', 0, ...
    'YRelativePosition', 0, ...
    'XPhysicalSize', FOVPhysicalSizeX, ...
    'YPhysicalSize', FOVPhysicalSizeY);

% FOV added to the center
n = navigator(); n.load(library); % load library to show

%% Task for Arunima:
%1. place the image to the FOV added to navigator
% Creates a channel for the monochromatic image to display in blue. 
monoChannel = spcore.ui.navigator.Channel('Name', 'Image', ...
    'Color', 'blue', ...
    'CLim', [0 2^16-1], ...
    'CRange', [0, 2^16-1], ...
    'Enable', true);
% Flips the plate and scales the axes accordingly. 
plateScale = [sign(0.5 - plate.XReverse), -sign(0.5 - plate.YReverse)];
% Transforms the image to fit in the field of view. 
T = spcore.ui.navigator.Image.getTransformation(...
    'Rotate', 0, ... 
    'Scale', plateScale .* [FOVPhysicalSizeX FOVPhysicalSizeY], ...
    'Translate', [FOVStageCoor.X FOVStageCoor.Y]/1000 - ...
    plateScale .* [FOVPhysicalSizeX/2 FOVPhysicalSizeY/2] ./([FOVPhysicalSizeX FOVPhysicalSizeY]));
% Adds the custom image onto the plate
mMono = monoChannel.addImage(...
    'CData', FOVImage, ...
    'Transformation', T);
% Updates the navigator with the image and zooms in on the selected well. 
n.addChannel('Channel', monoChannel);
n.CurrentObject = FOVWell;
n.zoomFit('selected'); 

% 3. challenging question: can you rotate the FOV? (this requires reading
% the actual code of planner's addFOV method and chase down the chain to see
% if you can tilt the FOV in any way.) 