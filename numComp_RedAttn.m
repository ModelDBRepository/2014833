% Author: Angela Rose
% Script initialises variables to run the symbolic number comparison task for LMA (no
% impairment) and HMA (with numerical size impaired).


taskType = 2;

% Also need to ensure NumStroopCogConNetwork.applyDamage has the impairment set correctly
% for the values of damageTypeArr set here. eg set to 0.95 for 95% impairment.
damageTypeArr = [0 7]; 

displayComparisonGraphs = true;
plotNDE = true;
displaySizeEffect = false;
displayChgThreshold = false;
displayDifferentNoLearningTrials = false;
labelNumLearningTrials = false;
plotConflict = false;
itemFile = 'inputdata_2cols_AllCombos1_9.txt'; 
randomizeInputFilePairs = true;
setDCWeights=3; 
wi2rNumRel = 0.85;
wi2rPhysIrrel = 0.9;
actTDNum = 1.0;
actTDPhys = 0.15;
displaySimBarGraphs = false;
displaySimResults = true;
displayStats = true;