% Author: Angela Rose
% Script initialises variables to run the symbolic number comparison task 
% for different values of the number of learning trials, and plot the NDE.


taskType = 2;

damageTypeArr = [17000 24000 30000 100000];

displayComparisonGraphs = true;
plotNDE = true;
displaySizeEffect = false;
displayChgThreshold = false;
displayDifferentNoLearningTrials = false;
labelNumLearningTrials = true;
plotConflict = false;
itemFile = 'inputdata_2cols_AllCombos1_9.txt'; 
randomizeInputFilePairs = true;
setDCWeights=4; 
wi2rNumRel = 0.85;
wi2rPhysIrrel = 0.9;
actTDNum = 1.0;
actTDPhys = 0.15;
displaySimBarGraphs = false;
displaySimResults = true;
displayStats = false;