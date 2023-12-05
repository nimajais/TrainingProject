% testing script for Singlecell_2P....PA for james
% cfg

% cfg = db.jobConfig('inputA', 'A', 'inputB', 123, 'inputB\nested', "???")
cfg = db.jobConfig('path', '\\10.21.17.86\s\Images\James\2023_09_25_IMPA001_secondary', ...
    'tgtCh\beforePA\path', 'X1024Y1024S4(2)_RFP\Before_PA', ...
    'tgtCh\beforePA\ch', 1, ...
    'tgtCh\beforePA\f', 1, ...
    'tgtCh\beforePA\frame', 1, ...
    'tgtCh\afterPA\path', 'X1024Y1024S4(2)_RFP\After_PA', ...
    'tgtCh\afterPA\ch', 1, ...
    'tgtCh\afterPA\f', 1, ...
    'tgtCh\afterPA\frame', 1, ...
    'refch\beforePA\path', 'X1024Y1024S4(3)_GFP\Before_PA', ...
    'refch\beforePA\ch', 1, ...
    'refch\beforePA\f', 1, ...
    'refch\beforePA\frame', 1, ...
    'refch\afterPA\path', 'X1024Y1024S4(3)_GFP\After_PA', ...
    'refch\afterPA\ch', 1, ...
    'refch\afterPA\f', 1, ...
    'refch\afterPA\frame', 1, ...
    'segmenter\matchingRule', '<filename>_<series>.tiff', ...
    'segmenter\maskFolder', 'GFP_AfterPA_MaskCellpose', ...
    'tgtCh\noiseLevel', 0, ...
    'refCh\noiseLevel', 0);


