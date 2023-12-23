% Author: Angela Rose
% Script initialises variables to run the numerical Stroop task for LMA (no
% impairment) and HMA (with numerical size impaired and not physical size
% impaired).


taskType = 1;

% Also need to ensure NumStroopCogConNetwork.applyDamage has the impairment set correctly
% for the values of damageTypeArr set here. eg set to 0.95 for 95% impairment.
damageTypeArr = [0 7]; 

displayComparisonGraphs = true;
plotNDE = false;
displaySizeEffect = false;
displayChgThreshold = false;
displayDifferentNoLearningTrials = false;
labelNumLearningTrials = false;
plotConflict = true;
itemFile = 'inputdata_4cols_1_Suarez16_2physsize.txt';
randomizeInputFilePairs = true;
setDCWeights=3; 
wi2rNumRel = 0.85;
wi2rPhysIrrel = 0.9;
actTDNum = 1.0;
actTDPhys = 0.15;
displaySimBarGraphs = false;
displaySimResults = true;
displayStats = true;