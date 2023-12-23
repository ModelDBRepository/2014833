% Author: Angela Rose
% Script initialises variables to run the physical Stroop task for 
% specified number of learning trials. 
% Note: The code was not written to be able to run the physical Stroop
% task. So the num and phys fields were swapped to be able to run it, and
% when results are printed out they need to be read as the opposite to what
% is written. This is also true for the generated graphs.
% eg. The num field in the code and in the results refers to
% the phys field, and vice versa.


taskType = 1;

damageTypeArr = [17000]; 

displayComparisonGraphs = false;
plotNDE = false;
displaySizeEffect = false;
displayChgThreshold = false;
displayDifferentNoLearningTrials = false;
labelNumLearningTrials = false;
plotConflict = false;
itemFile = 'inputdata_4cols_1_Suarez144.txt';
randomizeInputFilePairs = true;
setDCWeights=4; 
%wi2rNumRel = 0.85;
%wi2rPhysIrrel = 0.9;
wi2rNumRel = 0.9; % Phyiscal path is more automatic than numerical so swap these around.
wi2rPhysIrrel = 0.85;
actTDNum = 1.0;  % Task demands attention to the physical size as deciding which number is physically larger.
actTDPhys = 0.15;
displaySimBarGraphs = true;
displaySimResults = true;
displayStats = false;