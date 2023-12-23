% Author: Angela Rose
% Script initialises variables to run the numerical Stroop task 
% for different values of the number of learning trials, plots RTs and 
% % Errors.


taskType = 1;

damageTypeArr = [10000 17000 18000 19000 20000 21000 22000 23000 24000 25000 30000 100000]; 

displayComparisonGraphs = false;
plotNDE = false;
displaySizeEffect = false;
displayChgThreshold = false;
displayDifferentNoLearningTrials = true;
labelNumLearningTrials = true;
plotConflict = false;
itemFile = 'inputdata_4cols_1_Suarez144.txt';
randomizeInputFilePairs = true;
setDCWeights=4; 
wi2rNumRel = 0.85;
wi2rPhysIrrel = 0.9;
actTDNum = 1.0;
actTDPhys = 0.15;
displaySimBarGraphs = false;
displaySimResults = true;
displayStats = false;