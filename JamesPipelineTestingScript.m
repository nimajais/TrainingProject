% testing script for Singlecell_2P....PA for james
% cfg

% cfg = db.jobConfig('inputA', 'A', 'inputB', 123, 'inputB\nested', "???")
cfg = db.jobConfig('path', '\\10.21.17.86\s\Images\James\2023_09_25_IMPA001_secondary', ...
    'tgtCh\beforePA\path', 'X1024Y1024S4(2)_RFP\Before_PA', ...
    'tgtCh\beforePA\ch', 1, ...
    'tgtCh\beforePA\f', 0, ...
    'tgtCh\beforePA\frame', 1, ...
    'tgtCh\afterPA\path', 'X1024Y1024S4(2)_RFP\After_PA', ...
    'tgtCh\afterPA\ch', 1, ...
    'tgtCh\afterPA\f', 0, ...
    'tgtCh\afterPA\frame', 1, ...
    'refch\beforePA\path', 'X1024Y1024S4(3)_GFP\Before_PA', ...
    'refch\beforePA\ch', 1, ...
    'refch\beforePA\f', 0, ...
    'refch\beforePA\frame', 1, ...
    'refch\afterPA\path', 'X1024Y1024S4(3)_GFP\After_PA', ...
    'refch\afterPA\ch', 1, ...
    'refch\afterPA\f', 0, ...
    'refch\afterPA\frame', 1, ...
    'segmenter\matchingRule', '<filename>_<series>.tiff', ...
    'segmenter\maskFolder', 'GFP_AfterPA_MaskCellpose', ...
    'tgtCh\noiseLevel', 0, ...
    'refCh\noiseLevel', 0);


%% debugging 
M = T_fovData.SatuMask{1};

I = fov(1).Frame{'C', 2, 'T', '@(x) x(1)'}.getPixel();
spcore.image.bglevel(spcore.array.nanmasking(I, ~M), 16)

%% check FOVs
fov = lib.getChildren('fov');

I = fov(1).Frame{'C', 1, 'T', '@(x) x(1)'}.getPixel();
figure; imshow(I, []);

%% job Creation 
jobCode = 'Singlecell_2PPhotoActivationComparison';
jobInfo = struct('User', 'Test', 'ServerName', 'STPIERRESCOPE', 'Note', 'Test 1 File. Run by Haixin');
jobInput = {cfg};
job = spcore.job.Job.create(...
                'Code', jobCode, ...
                'Info', jobInfo, ...
                'Input', jobInput, ...
                'OutputVarNames', "T");