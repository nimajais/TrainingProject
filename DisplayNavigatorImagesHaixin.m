% script to simulate display the acquired images (FOV) in Navigator
%
% Haixin Liu, haixin.liu@bcm.edu
% St-Pierre Lab, Oct. 2023

%%
clear
%% whether to simulate microscope hardware
DebugMode = true; % false to communicate with hardware
%% define parameters:
% current use variable and struct to keep them
% TODO: need to implement class/config system to keep track of experimental
% parameters

PowerExciteGFP = 100; % check NIS nd2 file if not noted  TODO: reading directly from file?
PowerExciteBFP = 10; % check NIS nd2 file if not noted  TODO: reading directly from file?
PowerExciteRFP = 10; %
PowerPhotoActivation = 5; % DMD laser power, will be udpated late by user input

LightSourceChannelGFP = '470';
LightSourceChannelBFP = '405'; %?
LightSourceChannelPAImage = '555'; %?

UpperTurretPosition = 6; % Turret 1
LowerTurretPosition = 5; % Turret 2
% TODO: design light path variables/class

% define some common parameters:
cameraParams.GFP.ExposureTime = 0.1; % in second, check your image file
cameraParams.GFP.FrameCount = 1;
cameraParams.GFP.FrameRate = 1;
cameraParams.GFP.BinningHorizontal = 1;
cameraParams.GFP.BinningVertical = 1;
cameraParams.BFP.ExposureTime = 0.050; % in second, check your image file
cameraParams.BFP.FrameCount = 1;
cameraParams.BFP.FrameRate = 1;
cameraParams.BFP.BinningHorizontal = 1;
cameraParams.BFP.BinningVertical = 1;
cameraParams.RFP.ExposureTime = 0.015; % in second, check your image file
cameraParams.RFP.FrameCount = 1;
cameraParams.RFP.FrameRate = 1;
cameraParams.RFP.BinningHorizontal = 1;
cameraParams.RFP.BinningVertical = 1;

%% initialize hardware:
% Defines deviceManager as the different hardware associated with the
% microscope in room S636. 
deviceManager = ScopeConfigS636E(DebugMode); % dm = ScopeConfigS636B(DebugMode);
deviceManager.initialize();

% "NikonLightPathDrive"
% "NikonStage"
% "NikonZStage"
% "UpperTurret"
% "LowerTurret"
% "NikonDiaLight": sometimes this connection cable is in B room. Just
% comment out this device in ScopeConfigS636E.m file
% "NikonNosepiece"
% "NikonFocus"
% "NikonTiLApp"
% "89NorthLDILight"
% "DMD405Laser"
% "RightCamera"
% "LeftCamera"
% "ThorlabsDCServoStage"

Camera = deviceManager{'RightCamera'}; % Sets up the right camera in the program. 
deviceManager{'NikonLightPathDrive'}.setPosition(3);  % right: R100 button -> right camera

LightSource = deviceManager{'89NorthLDILight'}; % Sets up light source 

Stage = deviceManager{"NikonStage"}; % Sets up stage 
ZStage = deviceManager{"NikonZStage"}; % Sets up Zstage 
Focus = deviceManager{"NikonFocus"}; % Sets up focus 

% lightSource setting
LightSource.setPower('Channel', LightSourceChannelGFP, 'Power', PowerExciteGFP); %
LightSource.setPower('Channel', LightSourceChannelBFP, 'Power', PowerExciteBFP); %
LightSource.setPower('Channel', LightSourceChannelPAImage, 'Power', PowerExciteRFP); %

% LightSource.setPower('Channel', '520', 'Power', 100);
LightSource.start();

% turret: mirrors of light path
%{
 Microscope Settings:   Microscope: Ti Microscope
  Nikon Ti, FilterChanger(Turret1): 6
  Nikon Ti, FilterChanger(Turret2): 5 (405/470/555/640 LDI)
  LightPath: R100
  PFS-S, mirror: Inserted
%}
% deviceManager{'UpperTurret'}.setPosition(1);  % 405 Notch --> red ish under scope eyepiece
% deviceManager{'UpperTurret'}.setPosition(2);
deviceManager{'UpperTurret'}.setPosition(UpperTurretPosition);  %  ?= Turrent 1 in NIS
deviceManager{'LowerTurret'}.setPosition(LowerTurretPosition);  % quad LDI  ?= Turrent 2 in NIS

% Sets up the light path 
la = deviceManager{'NikonTiLApp'};
la.setPosition('Branch', 'UpperMain', 'State', la.STATE.In);
la.setPosition('Branch', 'UpperSub', 'State', la.STATE.Out);

% photo activation
DMD405Laser = deviceManager{'DMD405Laser'};
%{
DMD405Laser.setPower('Power', 5);
% fprintf('Photoactivating...\n');
% time = 20;
% for j = 1:time
%     pause(1);
%     fprintf('.');
% end
% fprintf('\n');
% obj.dm{'DMD405Laser'}.setPower('Power', 0);
%}
disp('Done initiating CLM');
%% add helper functions (temporary)
% TODO: implement class/package
% Add the files that spcore.job.Config is part of to the helper folder
% variable. 
folderCLMHelper = fileparts(which('spcore.job.Config'));
% If the specified files can be found, add them to the folder.  
if exist(fullfile(folderCLMHelper(1:(strfind(folderCLMHelper, 'Sandbox')-1)), 'Sandbox', 'CLM', 'Helper'), 'dir') == 7
    folderCLMHelper = fullfile(folderCLMHelper(1:(strfind(folderCLMHelper, 'Sandbox')-1)), 'Sandbox', 'CLM', 'Helper');
% Otherwise throw an error for the user. 
else
    error('Cannot find helper functions folder path');
end
% Add the needed path and notify the user. 
addpath(folderCLMHelper);
disp('Helper functions added')
%% camera imaging setup
defineCamera(Camera, cameraParams.GFP);
%{
defineCamera(Camera, cameraParams.BFP);
%}
% Camera.stop(); % need to stop camera every time passing definition if
% there is definition already
% cameraDefinition = spcore.hardware.CaptureDefinition('Exposure', cameraExposureTime, ...
%     'FrameCount', cameraFrameCount, ...
%     'FrameRate', cameraFrameRate, ...
%     'BinningHorizontal', cameraBinningHorizontal, ...
%     'BinningVertical', cameraBinningVertical);
% Camera.defineCapture(cameraDefinition);
% disp('Done initiating camera capturing parameters');


%% Simulation uses previous saved result
if DebugMode
    experimentFolder = '\\10.21.17.86\s\Images\Haixin\SPOTLight\20230927\CLM';
    % load previous dataset
    Calibration = load(fullfile(experimentFolder, 'CalibrationInfo.mat'));
    ImageAcquisition = load(fullfile(experimentFolder, 'FOVData.mat'));
    ROIOUTlineMask = ImageAcquisition.ROIOUTlineMask;
    LibraryTable = load(fullfile(experimentFolder, 'LibraryTable.mat'));
    % remove ROI for now
    LibraryTable = rmfield(LibraryTable, 'ROI');
    library = spcore.reporter.getLibraryFromStandardOutput(LibraryTable);
    disp('Finished loading library protocol and plate');
    % do I need planner? protocol?
    protocol = spcore.Protocol('Name', 'Simulate Image Display', ...
    'Path', experimentFolder);
    planner = spcore.hardware.Planner(library);
    library.Protocol.Path = experimentFolder;
    plate = spcore.Plate.import(fullfile(experimentFolder,'plate.xml'));
    library.Protocol.setPlate(plate);
    % library.Protocol.Library  
    
else
    %% Aquire images: define plate and experimental protocol
    error('NOT implemented');
    % Please scriptSPOTLightPoineer for calibration and acquisition design
    % for now (Haixin 20231004)
    % Define experiment folder 
    experimentFolder = 'E:\Temp test\Haixin\20230922\CLM';
    % If this folder is in the directory (hence the 7), make a folder
    % called experiment folder. 
    if exist(experimentFolder, 'dir') ~= 7
        mkdir(experimentFolder)
    end
    plateID = 1;
    % Creates protocol. 
    protocol = spcore.Protocol('Name', 'Test experiment', ...
        'Path', experimentFolder);
    % Creates plate 
    plate = spcore.Plate.getDefault('PlateType', 'P24-1.5H-N', ... % P96-1.5H-N
        'scope', 'S636E Okolab', ...
        'ID', plateID);
    protocol.setPlate(plate);
    % Creates library with protocol. 
    library = spcore.Library('Protocol', protocol);
    planner = spcore.hardware.Planner(library);
    group = planner.addGroup();
    % currWellName = "A3"; % to add

    disp('Finished initialize protocol and plate');
    %% Test: please move stage to a good FOV, focus and test image capture
    % Notes to user:
    % Use this step to adjust imaging parameters and change above parameters
    % accordingly

    % move to A3 center, can skip is using manual method
    currWellName = 'D6';
    [currWellStage.X, currWellStage.Y] = plate.wellname2xy(currWellName);
    moveStage(Stage, currWellStage.X*1000, currWellStage.Y*1000);
    ZStage.getPosition
    Focus.getPosition
    % last time z positions for beads
    %{
    ZStage.setPosition(3249.1);
    Focus.setPosition(8425);
    %}
end


%% Use navigator & gater => TODO make a new wrapper to add interaction between g and n. (similar to spcore.reporter.visual.SingleCellVisualizer
disp('Setting up imaging protocol...')
n = navigator(); 
n.load(library); % load library to show
disp('Done setting up imaging protocol. Start imaging acquisition ...')
%
% design parameters:
% Creates matrices for channel and transformation. 
tmpChannel = [];
tmpTransformation = [];
channelColor = 'green'; % GFP
imageBits = 16; % need to fetch from meta data in the future
plateScale = [sign(0.5 - plate.XReverse), -sign(0.5 - plate.YReverse)];


fov = library.getChildren("fov");
w = library.getChildren("well");
pause(0.5);
n.CurrentObject = w;
n.zoomFit('selected');

n.CurrentObject = fov;
n.zoomFit('selected');
pause(0.5);
% loop through to simulate acquistion process
for i = 1:numel(fov)
    fprintf('FOV # %i\n', i);
    % create temporary monoChannel to add to navigator 
    currFOVimage = ImageAcquisition.FOVImage{i};
    
    if i == 1 % take a look at the image data type
        whos currFOVimage
    end
    % Calculates display range
    tmpDisplayRange = prctile(currFOVimage(:), [1 99.99]);
    % Creates a channel to display the image in 
    tmpChannel = spcore.ui.navigator.Channel( ...
        'Name', sprintf('FOV %i %s', i, channelColor), ...
        'Color', channelColor, ...
        'CLim', tmpDisplayRange, ...
        'CRange', [0, 2^imageBits-1], ...
        'Enable', true);
    % Transforms the image to properly fit in the FOV 
    tmpTransformation = spcore.ui.navigator.Image.getTransformation(...
        'Scale', ...
        plateScale .* [fov(i).XPhysicalSize fov(i).YPhysicalSize], ...
        'Translate', ...
        [fov(i).XPosition fov(i).YPosition]);
    % Adds the custom image onto the plate
    tmpChannel.addImage(...
        'CData', currFOVimage, ...
        'Transformation', tmpTransformation);
    % Updates the navigator with the image and zooms in on the selected well.
    n.addChannel('Channel', tmpChannel);

    pause(0.5);

end

%% show ROIs -> to do one by one? after each segmentation?
flagShowROIOutline = true; % if false, show as mask in nagivator
% Defines the number of FOVs  
nFOV = numel(fov);
% Defines the ROI as a cell array 
ROI = cell(nFOV,1);
% Defines the ROI Centroid FOV and ROV Stage Position 
ROICentroidFOV = cell(nFOV,1);
ROIStagePosition = cell(nFOV,1);

% calculate ROI stage cooridnates using calibrated camera info
rp = spcore.ROIProperty(); % to use its methods ROI properties
% ROI metrics to use
ROIIntensity = cell(nFOV,1);
ROIsize = cell(nFOV,1);

% use gator to display metrics and define gate
g = gater();
% position
g.Figure.Position = [400 550 400 300];

pb = progressbar('Range', nFOV, ...
    'Name', 'Segmentation of FOVs and displaying ROIs');

for iFOV = 1:nFOV
    % segment
    % tic;
    % Create mask 
    tmpMask = ImageAcquisition.FOVMask{iFOV}; % cellposeSegmenter.segment(ImageAcquisition.FOVImage{iFOV});
    % toc;
    pause(1);
    % Set FOV mask equal to created mask 
    FOVMask{iFOV} = tmpMask;
    % FOVMask{iFOV} = spcore.image.cleanMaskAreaDiamEdge(tmpMask, ...
    %     minROIArea, minROIEquivDiameter, edgeTolerance);
    
    clear tmpMask;

    % create ROI instances
    currMask = FOVMask{iFOV};
    ROI{iFOV} = spcore.ROI.create(currMask);
    ROI{iFOV}.setParent(fov(iFOV));
    % get ROI position and ROI metrics
    % if the ROI is empty (no mask) assign a value to its centroid and
    % stage position. 
    if ~isempty(ROI{iFOV})
        tmpData = rp.compute('ROI', ROI{iFOV}, 'Property', 'Centroid');
        ROICentroidFOV{iFOV} = tmpData.Centroid;
        ROIStagePosition{iFOV} = cellfun(@(x) ...
            map2StagePosition(x, [fov(iFOV).XPosition * 1000 fov(iFOV).YPosition * 1000], Calibration), ...
            tmpData.Centroid, 'UniformOutput', false);
        clear tmpData;
    
        [ROIIntensity{iFOV}, ~, ROIsize{iFOV}, ~] = spcore.array.groupfun(ImageAcquisition.FOVImage{iFOV}, cat(1, ROI{iFOV}.Index), @nanmean, 1:2, 'toCell', false);        
    end   

    % add metrics for ROI intensity and size to gator
    if isempty(g.Source) % no source available, add source first
        g.addSource("Name", "ROIIntensitity", "Data", ROIIntensity{iFOV}, ...
            "Continuous", true, "Unit", "a.u.", "DisplayName", "ROI Intensitity", ...
            "Description", "ROI mean pixel intensity");
        g.addSource("Name", "ROISize", "Data", ROIsize{iFOV}, ...
            "Continuous", true, "Unit", "pixel number", "DisplayName", "ROI Size", ...
            "Description", "ROI area pixel number");
        g.addAxes("XData", "ROISize", "YData", "ROIIntensitity");
        
        % figure(g.Figure); % ? to show bound as well?

        % g.deleteGate
        % delete(tmpGate) % delete all gates, delete dependent gate will
        % delete combination gate as well
    else % add new FOV data to gater need to feed a matrix
        % Concatenate the ROI intesnity and ROI size to create new data 
        tmpNewData = cat(2, ROIIntensity{iFOV}, ROIsize{iFOV});
        % Adds the new data to gater  
        g.addSourceRow("Data", tmpNewData);

    end
    
    % add ROI Outline layer, same thing as adding channel for FOV 
    ROIChannel = spcore.ui.navigator.Channel( ...
        'Name', sprintf('FOV %i ROI Outline', iFOV), ...
        'Description', 'ROI Outline', ...
        'Color', [1, 0.25, 0.25], ...
        'CLim', [0, 1], ...
        'CRange', [0, 2]);
    T = spcore.ui.navigator.Image.getTransformation(...
        'Scale', plateScale.*[fov(iFOV).XPhysicalSize, fov(iFOV).YPhysicalSize], ...
        'Translate', [fov(iFOV).XPosition, fov(iFOV).YPosition]);

    if ~flagShowROIOutline % Show ROI as mask
        ROIChannel.addImage(...
            'CDataSource', @() createROIMask(fov(iFOV)), ...
            'Transformation', T);
    else % Show ROI as outline: SLOW half min to process a FOV
        % ROIOUTlineMask{iFOV} = spcore.image.makeROIOutlineMask(currMask);
        % % use premade
        ROIChannel.addImage(...
            'CData', ROIOUTlineMask{iFOV}, ...
            'Transformation', T);
        % ROIChannel.addImage(...
        %     'CDataSource', @() spcore.image.makeROIOutlineMask(currMask), ...
        %     'Transformation', T);
    end
    n.addChannel('Channel', ROIChannel);
    pb.increment();
end

clear rp T ROIChannel currMask

%%
% for iFOV = 1:nFOV
%     ROIOUTlineMask{iFOV} = spcore.image.makeROIOutlineMask(ImageAcquisition.FOVMask{iFOV});
% end
% save(fullfile(experimentFolder, 'FOVData.mat'), '-append', 'ROIOUTlineMask');
%% display and draw predefined gates
% target parameters
targetSeletion.SizeLoBound = 2500;
targetSeletion.SizeHiBound = 3000;
targetSeletion.IntesnityLoBound = 110;
targetSeletion.IntesnityHiBound = 150;

% assume added sequence for the gate ID number -> to do last given
% gater errors if add and update data
MetricGate(1) = g.addFunctionalGate("Axes", g.Axes, ...
    "Name", "Size low bound", ...
    "Expression", string(['@(x, y) x - ', num2str(targetSeletion.SizeLoBound)]), ...
    "Polarity", ">=", "Visible", true);
MetricGate(2) = g.addFunctionalGate("Axes", g.Axes, ...
    "Name", "Size high bound", ...
    "Expression", string(['@(x, y) x - ', num2str(targetSeletion.SizeHiBound)]), ...
    "Polarity", "<=", "Visible", true);

MetricGate(3) =g.addFunctionalGate("Axes", g.Axes, ...
    "Name", "Intensity low bound", ...
    "Expression", string(['@(x, y) y - ', num2str(targetSeletion.IntesnityLoBound)]), ...
    "Polarity", ">=", "Visible", true);
MetricGate(4) =g.addFunctionalGate("Axes", g.Axes, ...
    "Name", "Intensity high bound", ...
    "Expression", string(['@(x, y) y - ', num2str(targetSeletion.IntesnityHiBound)]), ...
    "Polarity", "<=", "Visible", true);

MetricGate(5) =g.addCombinatorialGate("Expression","1 & 2 & 3 & 4");
MetricGate(5).Name = "Target";

% popup show Data hierarchy
% library.visualizeInstanceHierarchy;

%% zoom
n.CurrentObject = fov(2);
n.zoomFit('selected');
% n.zoomFit('tight');
%% delete channel can only do manually, as methods are private
%{
ch = n.getChannel();
            if isempty(ch)
                warning('No channel defined. Cannot select channel. ');
                spcore.ui.dialog.alert('Parent', me.Figure, ...
                    'Message', 'No channel is defined. Please add a channel first. ', ...
                    'Icon', 'warning', ...
                    'Title', 'Select Channel');
                return
            end

            channelName = strings(numel(ch), 1);
            for i = 1:numel(ch)
                channelName(i) = string(i) + ": " + ch(i).Name + ...
                    " (" + string(numel(ch(i).Children)) + " images)";
            end
            [idx, tf] = listdlg('ListString', channelName, ...
                'Name', 'Select Channel', ...
                'SelectionMode', 'multiple', ...
                'ffs', 0, ...
                'ListSize', [250, 160], ...
                'PromptString', p.Message);
            if tf == 0  % cancel
                return
            else
                s = ch(idx);
            end
delete(ch)
%}
%% Local functions

function I = createROIMask(f)
    % f: scalar FOV
    r = f.getChildren('r');
    index = cat(1, r.Index);
    I = logical(union(index));
end