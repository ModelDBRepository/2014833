% Author: Angela Rose
% Script initialises variables to run the numerical Stroop task for 
% different values of the threshold parameter, which simulates the
% speed-accuracy trade-off.


taskType = 1;

% Also need to ensure NumStroopCogConNetwork has the impairment set correctly
% for the values of damageTypeArr set here. 
damageTypeArr = [70 71 0 72 73]; 

displayComparisonGraphs = false;
plotNDE = false;
displaySizeEffect = false;
displayChgThreshold = true;
displayDifferentNoLearningTrials = false;
labelNumLearningTrials = false;
plotConflict = false;
itemFile = 'inputdata_4cols_1_Suarez144.txt';
randomizeInputFilePairs = true;
setDCWeights=3; 
wi2rNumRel = 0.85;
wi2rPhysIrrel = 0.9;
actTDNum = 1.0;
actTDPhys = 0.15;
displaySimBarGraphs = false;
displaySimResults = true;
displayStats = false;
