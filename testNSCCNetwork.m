% Script simulates a numerical Stroop task and a single-digit number comparison
% task. The numerical Stroop task involves deciding which of two
% single-digit numbers has largest magnitude, when presented in different
% (physical) size fonts.
%
% Copyright:
% The code has been adapted from the multisymbol number comparison model
% (supplemental materials) from the article:
% Huber S., Nuerk, H-C., Willmes, K., & Moeller, K. (2016). A general model
% framework for multisymbol number comparison. Psychological Review, 123,
% 667-695. https://doi.org/10.1037/rev0000040.
% Reproduced with permission from American Psychological
% Association. No further reproduction or distribution is permitted.
% Permission has also been granted by the authors (K. Moeller).
% The original code was written by Stefan Huber (s.huber@iwm-tuebingen.de)
% and was version 1.1, from experiment 1 of the article.

% The code has been adapted by:
% Angela Rose, Western Sydney University, Australia, for the degree of
% Master of Research, and for journal publishing of the results.

clear all;   

% Set the appropriate script to initialise variables from an external file for 
% different simulations (done as a script rather than .mat file so can change
% values easily while testing).

%%numStroop_Validation;
%%numStroop_PhysStroop;
%%numStroop_PhysStroopSCE;
numStroop_RedAttnNum;
%%numStroop_RedAttnPhys;
%%numStroop_RedAttnNumPhys;
%%numStroop_ChgThreshold;
%%numStroop_DiffNoLearningTrials;
%%numComp_RedAttn;
%%numComp_RedLearnWoAttnRed;
%%numComp_RedLearnRedAttn;
%%numComp_DiffNoLearnTrials;
%%numComp_NDEAcrossLearn;

% set the type of task: 1 for numerical Stroop; 2 for single-digit number
% comparison.
% Note: the output file for taskType=2 puts results into the Congruent
% field/column. And therefore % errors are 100 - %Hits Cong.
%%taskType = 1;

% Run simulation for each type of damage in array e.g. [0 7] runs 0 for LMA
% and 7 for HMA.
%%damageTypeArr = [0 7];
%damageTypeArr = [70 71 0 72 73];  % change threshold
%damageTypeArr = [20000 18000];  %number of learning trials
% To run for different number of learning trials, and set setDCWeights = 4
%damageTypeArr = [10000 17000 18000 19000 20000 21000 22000 23000 24000 25000 30000 100000];

% initialise variables for LMA/HMA comparison
resultsANNMatrix=[];
resultsMatrix=[];

%%displayComparisonGraphs = true; % display graphs comparing LMA and HMA on same figure
%%plotNDE = true; % plot the numerical distance effect
%%displaySizeEffect = false; % graph the Size Effect
%%displayChgThreshold = false; % graph the speed-accuracy trade-off 

%display graphs for comparing different number of learning trials
%%displayDifferentNoLearningTrials = false;  

% set true if convert damageTypeArr from number to label i.e., to convert
% 17000 to "17,000" on the graph. Else best set to false.
%%labelNumLearningTrials = false;

CR = ConflictResults();
% set flag to true/false for plotting the conflict/energy in response
% layer. Defaults to false.
CR.plotConflict = plotConflict;

switch taskType
    case 1
        outputFileData = strcat('numericalStroop','.csv');
    case 2
        outputFileData = strcat('numbercomp','.csv');
end
fileIDData = fopen(outputFileData, 'w');
headerTextData = {'Impair','ANN', 'trial', 'N1', 'N2', 'P1', 'P2', 'Succ.', 'Cong', '', 'Ndist', 'Pdist', 'NumSize', 'rt', ...
                    'conflict'};
formatSpecHdrData = '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n';
fprintf(fileIDData, formatSpecHdrData, headerTextData{1,:});
formatSpecDtlData = '%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%f\n';

for sim=damageTypeArr
    fprintf('Simulation Type: %d \n', sim);
    damageType=sim;
    % input file containing item set with 4 columns (separated by spaces or tabs):
    % Col 1: numerical size left. Col 2: numerical size right. 
    % Col 3: physical size left. Col 4: physical size right.
    %itemFile = 'inputdata_4cols_1_Suarez144.txt';  % This is the file used
    %for numerical Stroop to validate LMA which has 12x12 (144 pairs) of 1,2,8,9.
    
    %itemFile = 'inputdata_4cols_1_Suarez16_2physsize.txt';   %Suarez dataset 16 unique combinations (this set used for LMA and HMA for Stroop)
    %itemFile = 'inputdata_2cols_AllCombos1_9.txt';     % All single digit combinations of which number is greater (72 trials). ie Dietrich et al.(2015) 

    % comma delimitered file to write output data, named based on type of task
    switch taskType
        case 1
            outputFile = strcat('numericalStroop_',num2str(damageType),'.csv');
        case 2
            outputFile = strcat('numbercomp1_',num2str(damageType),'.csv');
    end
    fileID = fopen(outputFile, 'w');
    headerText = {'ANN', 'trial', 'N1', 'N2', 'P1', 'P2', 'Succ.', 'Cong', 'Ndist', 'Ndist', 'Pdist', 'Pdist', 'rt', ...
                    'a1', 'a2', 'x_acc', '', 'cur_conflict', 'mean_conflict', '', ...
                    'wT2I_1_NL', 'wT2I_2_NR', 'wT2I_3_PL', 'wT2I_4_PR', '', 'emp_rt', 'Size'};
    formatSpecHdr = '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n';
    fprintf(fileID, formatSpecHdr, headerText{1,:});
    formatSpecDtl = '%d,%d,%d,%d,%d,%d,%d,%s,%d,%s,%d,%s,%d,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%s\n';

    % number of neural networks to train/test
    numTestANN = 30;

    % Numerical Stroop - 2 single digit comparison networks: numerical size and
    % physical size. For Huber this parameter was number of integer digits.
    % For number comparison task don't use physical size network.
    switch taskType
        case 1
            numSingleDigitComparisonNetworks = 2;     
        case 2
            numSingleDigitComparisonNetworks = 1;   
    end

    numDecimalDigits_Unused = 0;            % kept from Huber (was number of digits after decimal point)

    % randomise the input file. 
    %%randomizeInputFilePairs = true;

    DS = DamageSettings(damageType);

    % Flag for how to train the single digit comparison networks:
    % 0 = Use the saved weights specified in DCNetwork.m as per Huber et al.,
    % weights were trained on one single digit comparison network and then
    % saved and copied to the other comparison networks. Weights remain the
    % same for all participants. (Note this has a node for the number zero.)
    % 1 = Train one single digit comparison network and copy the weights to the
    % other single digit comparison network. Repeat this process for each
    % participant so that each has a different set of weights.
    % 2 = Training is done as per Santens and Verguts (2011), where the
    % numerical size and physical size comparison networks are trained
    % separately. The weights are not reused, each participant is trained
    % separately, and therefore have different weights.
    % 3 = Training is done as per #2 but weights have been saved previously from running script trainDCNetwork.m and
    % are loaded into program from an external file. Each single digit comparison network in every ANN is
    % different. 4 sets of 18 weights are required for each ANN (to num Size L
    % node, num size R node, phys size L node, phys size R node). Note because
    % weights are set from an external file and loaded for both LMA and HMA,
    % every ANN in LMA is the same as for HMA.
    % e.g. ANN 1 LMA = ANN 1 HMA, ANN 2 LMA = ANN 2 HMA and so on.
    % 4 = Training is done as per #3 but allows different weights to be
    % used for each of the different types of damage types (e.g. different
    % weights for LMA and for HMA.

    %%setDCWeights=3; 
    %setDCWeights=4;
                        
    if (setDCWeights == 3 || setDCWeights == 4)
    
        switch setDCWeights
            case 3
                % weights used for numerical Stroop and number comparison where
                % training is kept as is at 100000 training trials
                wfid = fopen('savedWeightsI2O_100ANN_LR01_G_NoZero.csv');
            case 4
                switch sim
                    case 0
                        wfid = fopen('savedWeightsI2O_30ANN_LR01_G_20000.csv'); 
                    case {53, 7}
                        %use 53 for running different weights for LMA and HMA.
                        %I've put 7 here if want to use different weights but
                        %impair attention as well. 
                        wfid = fopen('savedWeightsI2O_30ANN_LR01_G_18000.csv');   %number comparison training trials 18000
                    case {10000}
                        wfid = fopen('savedWeightsI2O_30ANN_LR01_G_10000.csv');   %number comparison training trials 10000
                    case {17000}
                        wfid = fopen('savedWeightsI2O_30ANN_LR01_G_17000.csv');   %number comparison training trials 17000
                    case {18000}
                        wfid = fopen('savedWeightsI2O_30ANN_LR01_G_18000.csv');   %number comparison training trials 18000
                    case {19000}
                        wfid = fopen('savedWeightsI2O_30ANN_LR01_G_19000.csv');   %number comparison training trials 19000                 
                    case {20000}
                        wfid = fopen('savedWeightsI2O_30ANN_LR01_G_20000.csv');   %number comparison training trials 20000    
                    case {21000}
                        wfid = fopen('savedWeightsI2O_30ANN_LR01_G_21000.csv');   %number comparison training trials 21000
                    case {22000}
                        wfid = fopen('savedWeightsI2O_30ANN_LR01_G_22000.csv');   %number comparison training trials 22000
                    case {23000}
                        wfid = fopen('savedWeightsI2O_30ANN_LR01_G_23000.csv');   %number comparison training trials 23000
                    case {24000}
                        wfid = fopen('savedWeightsI2O_30ANN_LR01_G_24000.csv');   %number comparison training trials 24000
                    case {25000}
                        wfid = fopen('savedWeightsI2O_30ANN_LR01_G_25000.csv');   %number comparison training trials 25000    
                    case {30000}
                        wfid = fopen('savedWeightsI2O_30ANN_LR01_G_30000.csv');   %number comparison training trials 30000    
                    case {100000}
                        wfid = fopen('savedWeightsI2O_100ANN_LR01_G_NoZero.csv');   %number comparison training trials 100000
                    %otherwise
                    %   wfid = fopen('savedWeightsI2O_30ANN_LR01_G_30000.csv');   %number comparison training trials 30000
                end
        end
    
        W= textscan(wfid, '%18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f\n');
        fclose(wfid);
        DCNWeightsI2O_FromFile = [W{1} W{2} W{3} W{4} W{5} W{6} W{7} W{8} W{9} W{10} W{11} W{12} W{13} W{14} W{15} W{16} W{17} W{18}];
        DCNWeightsI2O_FromFile = DCNWeightsI2O_FromFile';  %transpose into column vectors for each set of 18 weights as in DCNetwork.weightsI2O
    else
        DCNWeightsI2O_FromFile = [];
    end

    % Flag to specify how to generate the number pairs when training the
    % comparison networks (i.e., the frequency of numbers presented to the
    % model):
    % G  = Train using a Google distribution, which weights lower numbers more
    % and is required to simulate the problem size effect. 
    % U0 = Train using a Uniform distribution where all numbers generated are
    % weighted evenly.
    % U1 = Train using a Uniform distribution where the number zero is weighted
    % more than other numbers. This does not currently work as removed node
    % zero for numerical stroop.
    trainPairs = 'G';

    % sets the distance between the numbers as small if <=smallDistLimit.
    % For Suarez et al. (2014) dataset (i.e., 1, 2, 8, 9)
    % set to 6. Note that this is only used if reporting/graphing by
    % small/large. If report/graph by distance between the numbers then this is
    % not used.
    smallDistLimit = 6;
    SR = StroopResults(smallDistLimit);

    % weights between comparison layer and response layer for
    % numerical/relevant and physical/irrelevant. Physical dimension is more
    % automatic thus stronger weights.
    %%wi2rNumRel = 0.85;
    %%wi2rPhysIrrel = 0.9;

    % activation of task demand nodes for numerical size and physical size.
    % [Note: Code was not written to be able to handle physical Stroop so some of the
    % num and phys fields were swapped around to be able to run but the
    % results/output has some of them still swapped ie num meant phys etc. ]
    %%actTDNum = 1.0;
    %%actTDPhys = 0.15;
    switch taskType
        case 1
            taskVector= [actTDNum; actTDPhys];
        case 2
            taskVector= [actTDNum];
    end

    %%displaySimBarGraphs = false;
    %%displaySimResults = true;
    %%displayStats = false;

    for i=1:numTestANN
        fprintf('Participant: %d \n', i);
        % Initialize ANN
        NSCCN = NumStroopCogConNetwork(taskType, numSingleDigitComparisonNetworks, numDecimalDigits_Unused, taskVector, wi2rNumRel, wi2rPhysIrrel, setDCWeights, i, DCNWeightsI2O_FromFile, trainPairs);
        % read itemFile and simulate data
        % AdaptionTypes.AdaptWeightsT2I =  sets adaptation to weights between 
        % task demand layer and comparison layer as per algorithm of Verguts
        % and Notebaert (2008). Note: Huber et al. uses an error signal instead
        % (which is not used for numerical Stroop): AdaptionTypes.AdaptTaskNodes.
        % Set AdaptionTypes.NoAdaptation for no adaptation of weights at end of
        % each trial.
        % Square brackets contains trials to break after e.g. [32; 64; 96; 128], or leave empty [].
        NSCCN.testListFromFile(itemFile, AdaptionTypes.NoAdaptation, [], randomizeInputFilePairs, i, SR, DS, CR);
        % write simulated data to a comma delimitered file
        NSCCN.writeItemSetToTextFile(fileID, formatSpecDtl);
    end

    fclose(fileID);
            
    for idx = 1:SR.arrResultsIdx
        if isnan(SR.arrResults(idx,1))
            break
        end
        fprintf(fileIDData, formatSpecDtlData, damageType, SR.arrResults(idx,:));
        resultsMatrix = [resultsMatrix; damageType, SR.arrResults(idx,:)];
    end

    %%%% Output overall numerical Stroop results %%%%
    
    % (Note: data has been recalculated into several variables / output files.
    % Some are redundant and could be reduced so calculations only occur once.
    % Some of the code for the figures is also repeated, which could
    % be put into a separate script.)

    % overall means
    % in mean calculation in brackets: first part is selected/filtered
    % rows, second part is column to take mean of
    meanCong = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1,SR.colRT),'omitnan');
    meanIncong = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0,SR.colRT),'omitnan');
    %stdCong = std(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1,SR.colRT),'omitnan');
    %stdIncong = std(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0,SR.colRT),'omitnan');
    meanSCE = meanIncong - meanCong;
 
    meanNumDistLarge = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit,SR.colRT),'omitnan');
    meanNumDistSmall = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
    meanPhysDistSmall = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
    meanPhysDistLarge = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,SR.colRT),'omitnan');
    %stdNumDistLarge = std(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit,SR.colRT),'omitnan');
    %stdNumDistSmall = std(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
    %stdPhysDistSmall = std(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
    %stdPhysDistLarge = std(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,SR.colRT),'omitnan');
    
    % the distance between the numbers
    meanNumDist1 = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==1,SR.colRT),'omitnan');
    meanNumDist2 = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==2,SR.colRT),'omitnan');
    meanNumDist3 = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==3,SR.colRT),'omitnan');
    meanNumDist4 = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==4,SR.colRT),'omitnan');
    meanNumDist5 = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==5,SR.colRT),'omitnan');
    meanNumDist6 = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==6,SR.colRT),'omitnan');
    meanNumDist7 = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==7,SR.colRT),'omitnan');
    meanNumDist8 = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==8,SR.colRT),'omitnan');
    meanNumDist9 = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==9,SR.colRT),'omitnan');
    
    %std dev
    %stdNumDist1 = std(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==1,SR.colRT),'omitnan');
    %stdNumDist2 = std(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==2,SR.colRT),'omitnan');
    %stdNumDist3 = std(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==3,SR.colRT),'omitnan');
    %stdNumDist4 = std(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==4,SR.colRT),'omitnan');
    %stdNumDist5 = std(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==5,SR.colRT),'omitnan');
    %stdNumDist6 = std(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==6,SR.colRT),'omitnan');
    %stdNumDist7 = std(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==7,SR.colRT),'omitnan');
    %stdNumDist8 = std(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==8,SR.colRT),'omitnan');
    %stdNumDist9 = std(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==9,SR.colRT),'omitnan');

    %problem size effect (only for size 1 atm)
    meanDist1SizeSmall = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==1 & SR.arrResults(:,SR.colNumSize)==1,SR.colRT),'omitnan');
    meanDist1SizeLarge = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==1 & SR.arrResults(:,SR.colNumSize)==9,SR.colRT),'omitnan');
    
    %amount of response conflict
    meanConflictCong = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1,SR.colConflict),'omitnan');
    meanConflictIncong = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0,SR.colConflict),'omitnan');
    meanSCEConflict = meanConflictIncong - meanConflictCong;

    meanCongNumDistLarge = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit,SR.colRT),'omitnan');
    meanIncongNumDistLarge = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit,SR.colRT),'omitnan');
    meanSCENumDistLarge = abs(meanCongNumDistLarge - meanIncongNumDistLarge);

    meanCongNumDistSmall = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
    meanIncongNumDistSmall = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
    meanSCENumDistSmall = abs(meanCongNumDistSmall - meanIncongNumDistSmall);

    meanCongPhysDistSmall = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
    meanIncongPhysDistSmall = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
    meanSCEPhysDistSmall = abs(meanCongPhysDistSmall - meanIncongPhysDistSmall);

    meanCongPhysDistLarge = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,SR.colRT),'omitnan');
    meanIncongPhysDistLarge = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,SR.colRT),'omitnan');
    meanSCEPhysDistLarge = abs(meanCongPhysDistLarge - meanIncongPhysDistLarge);
 
    % Overall means and number of successful trials for 8 groups - have used Santens and Verguts
    % terminology of close/far for distances

    meanCongNumClosePhysFar = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,SR.colRT),'omitnan');
    meanCongNumClosePhysClose = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
    meanCongNumFarPhysFar = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,SR.colRT),'omitnan');
    meanCongNumFarPhysClose = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
    meanIncongNumClosePhysFar = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,SR.colRT),'omitnan');
    meanIncongNumClosePhysClose = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
    meanIncongNumFarPhysFar = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,SR.colRT),'omitnan');
    meanIncongNumFarPhysClose = mean(SR.arrResults(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
    sumCongNumClosePhysFar = sum(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,'omitnan');
    sumCongNumClosePhysClose = sum(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,'omitnan');
    sumCongNumFarPhysFar = sum(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,'omitnan');
    sumCongNumFarPhysClose = sum(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,'omitnan');
    sumIncongNumClosePhysFar = sum(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,'omitnan');
    sumIncongNumClosePhysClose = sum(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,'omitnan');
    sumIncongNumFarPhysFar = sum(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,'omitnan');
    sumIncongNumFarPhysClose = sum(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,'omitnan');

    % calc SCE for % Hits (i.e., %successes)
    sumSuccessCong = sum(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1,'omitnan');
    sumSuccessIncong = sum(SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0,'omitnan');
    sumTotalCongTrials = sum(SR.arrResults(:,SR.colCongruity)==1,'omitnan');
    sumTotalIncongTrials = sum(SR.arrResults(:,SR.colCongruity)==0,'omitnan');
    sumTotalTrials = sumTotalCongTrials + sumTotalIncongTrials;
    sumErrorTOTrials = sum(SR.arrResults(:,SR.colSuccess)==0 | SR.arrResults(:,SR.colSuccess)==2,'omitnan');
    hitsPercentCong = sumSuccessCong / sumTotalCongTrials * 100;
    hitsPercentIncong = sumSuccessIncong / sumTotalIncongTrials * 100;
    hitsPercentSCE = hitsPercentCong - hitsPercentIncong;

    % Total number of trials included in the RT analysis. Will have error
    % trials.
    sumTotalInclTrials = sumCongNumClosePhysFar + sumCongNumClosePhysClose + sumCongNumFarPhysFar + sumCongNumFarPhysClose + ...
                        sumIncongNumClosePhysFar + sumIncongNumClosePhysClose + sumIncongNumFarPhysFar + sumIncongNumFarPhysClose;
                    
    % for reporting to screen (not for reporting in output results file)
    sumErrors = sum(SR.arrResults(:,SR.colSuccess)==0, 'omitnan');
    totalTrials = sum(~isnan(SR.arrResults(:,SR.colANN))); 
    percentErrors = sumErrors / totalTrials * 100;
    sumTimeouts = sum(SR.arrResults(:,SR.colSuccess)==2);

    %%%% Output numerical Stroop results by ANN/participant %%%%

    % write summary results for each ANN/participant to a separate .csv file
    % Note: ensure when opening .csv file to specify comma delimitered data
    % and not space delimitered, otherwise headers will not display correctly.
    resultsANNFile = strcat('resultsANN_',num2str(damageType),'.csv');
    fileID = fopen(resultsANNFile, 'w');

    headerText = {'ANN', 'Total', 'Error/TO', 'Incl', '%', '%', '%', 'Congruent', 'Incongruent', 'SCE', ... 
        'Num Dist', 'Num Dist', 'Phys Dist', 'Phys Dist', ... 
        'Congruent', 'Incongruent', 'Congruent', 'Incongruent', 'SCE', 'SCE', ...
        'Congruent', 'Incongruent', 'Congruent', 'Incongruent', 'SCE', 'SCE', ...
        'Congruent', 'Congruent', 'Congruent', 'Congruent', 'Incongruent', 'Incongruent', 'Incongruent', 'Incongruent', ...
        'Congruent', 'Congruent', 'Congruent', 'Congruent', 'Incongruent', 'Incongruent', 'Incongruent', 'Incongruent', ...
        'Size', 'Size', ...
        'Response', 'Response', 'Response', ...
        'Num', 'Num', 'Num', 'Num', 'Num', 'Num', 'Num', 'Num'};
    formatSpecHdr = '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n';
    fprintf(fileID, formatSpecHdr, headerText{1,:});
    headerText = {'', '# Trials', '# Trials', '# Trials', 'Hits', 'Hits', 'Hits', '', '', 'I-C', ... 
        'Far', 'Close', 'Far', 'Close', ...
         'Num Dist', 'Num Dist', 'Num Dist', 'Num Dist', 'Num Dist', 'Num Dist', ...
        'PhysDist', 'PhysDist', 'Phys Dist', 'PhysDist', 'PhysDist', 'Phys Dist', ...
        'Num Far', 'Num Far', 'Num Close', 'Num Close', 'Num Far', 'Num Far', 'Num Close', 'Num Close', ...
        'Num Far', 'Num Far', 'Num Close', 'Num Close', 'Num Far', 'Num Far', 'Num Close', 'Num Close', ...
        '1', '1', ...
        'Conflict', 'Conflict', 'Conflict', ...
        'Dist', 'Dist', 'Dist', 'Dist', 'Dist', 'Dist', 'Dist', 'Dist'};
    fprintf(fileID, formatSpecHdr, headerText{1,:});
    headerText = {'', '', '', '', 'C','I','C-I', '', '', '', ...  
        '', '', '', '', ...
        'Far', 'Far', 'Close', 'Close', 'Far', 'Close', ...
        'Far', 'Far', 'Close', 'Close', 'Far', 'Close', ...
        'Phys Far', 'Phys Close', 'Phys Far', 'Phys Close', 'Phys Far', 'Phys Close', 'Phys Far', 'Phys Close', ...
        'Phys Far', 'Phys Close', 'Phys Far', 'Phys Close', 'Phys Far', 'Phys Close', 'Phys Far', 'Phys Close', ... 
        '1 vs 2', '8 vs 9', ...
        'Cong', 'Incong', 'I-C', ...
        '1', '2', '3', '4', '5', '6', '7', '8'};
    fprintf(fileID, formatSpecHdr, headerText{1,:});
    headerText = {'', '', '', '', '', '', '', 'Mean', 'Mean', 'Mean', ...
        'Mean', 'Mean', 'Mean', 'Mean', ...
        'Mean', 'Mean', 'Mean', 'Mean', '|I-C|', '|I-C|', ...
        'Mean', 'Mean', 'Mean', 'Mean', '|I-C|', '|I-C|', ...
        '#Trials', '#Trials', '#Trials', '#Trials', '#Trials', '#Trials', '#Trials', '#Trials', ...
        'Mean', 'Mean', 'Mean', 'Mean', 'Mean', 'Mean', 'Mean', 'Mean', ...
        'Mean', 'Mean', ...
        'Mean', 'Mean', 'Mean', ...
        'Mean', 'Mean', 'Mean', 'Mean', 'Mean', 'Mean', 'Mean', 'Mean'};
    fprintf(fileID, formatSpecHdr, headerText{1,:});
    formatSpecDtl = '%d,%d,%d,%d,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%d,%d,%d,%d,%d,%d,%d,%d,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n';

    for r = 1:numTestANN
        sumANNCongNumClosePhysFar = sum(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,'omitnan');
        sumANNCongNumClosePhysClose = sum(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,'omitnan');
        sumANNCongNumFarPhysFar = sum(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,'omitnan');
        sumANNCongNumFarPhysClose = sum(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,'omitnan');
        sumANNIncongNumClosePhysFar = sum(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,'omitnan');
        sumANNIncongNumClosePhysClose = sum(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,'omitnan');
        sumANNIncongNumFarPhysFar = sum(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,'omitnan');
        sumANNIncongNumFarPhysClose = sum(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,'omitnan');
    
        meanANNCongNumClosePhysFar = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,SR.colRT),'omitnan');
        meanANNCongNumClosePhysClose = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
        meanANNCongNumFarPhysFar = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,SR.colRT),'omitnan');
        meanANNCongNumFarPhysClose = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
        meanANNIncongNumClosePhysFar = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,SR.colRT),'omitnan');
        meanANNIncongNumClosePhysClose = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
        meanANNIncongNumFarPhysFar = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,SR.colRT),'omitnan');
        meanANNIncongNumFarPhysClose = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,SR.colRT),'omitnan');

        meanANNCong = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1,SR.colRT),'omitnan');
        meanANNIncong = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0,SR.colRT),'omitnan');
        meanANNSCE = meanANNIncong - meanANNCong;
 
        meanANNNumDistLarge = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit,SR.colRT),'omitnan');
        meanANNNumDistSmall = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
        meanANNPhysDistSmall = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
        meanANNPhysDistLarge = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,SR.colRT),'omitnan');
    
        meanANNCongNumDistLarge = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit,SR.colRT),'omitnan');
        meanANNIncongNumDistLarge = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colNumDist)>SR.smallDistLimit,SR.colRT),'omitnan');
        meanANNCongNumDistSmall = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
        meanANNIncongNumDistSmall = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colNumDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
        meanANNCongPhysDistSmall = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
        meanANNIncongPhysDistSmall = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colPhysDist)<=SR.smallDistLimit,SR.colRT),'omitnan');
        meanANNCongPhysDistLarge = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1 & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,SR.colRT),'omitnan');
        meanANNIncongPhysDistLarge = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0 & SR.arrResults(:,SR.colPhysDist)>SR.smallDistLimit,SR.colRT),'omitnan');
    
        meanANNDist1SizeSmall = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==1 & SR.arrResults(:,SR.colNumSize)==1,SR.colRT),'omitnan');
        meanANNDist1SizeLarge = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==1 & SR.arrResults(:,SR.colNumSize)==9,SR.colRT),'omitnan');
      
        meanANNNumDist1 = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==1,SR.colRT),'omitnan');
        meanANNNumDist2 = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==2,SR.colRT),'omitnan');
        meanANNNumDist3 = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==3,SR.colRT),'omitnan');
        meanANNNumDist4 = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==4,SR.colRT),'omitnan');
        meanANNNumDist5 = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==5,SR.colRT),'omitnan');
        meanANNNumDist6 = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==6,SR.colRT),'omitnan');
        meanANNNumDist7 = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==7,SR.colRT),'omitnan');
        meanANNNumDist8 = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colNumDist)==8,SR.colRT),'omitnan');
        
        meanANNConflictCong = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1,SR.colConflict),'omitnan');
        meanANNConflictIncong = mean(SR.arrResults(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0,SR.colConflict),'omitnan');
        meanANNSCEConflict = meanANNConflictIncong - meanANNConflictCong;
    
        % calc SCE for % Hits (i.e., %successes) 
        sumANNSuccessCong = sum(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==1,'omitnan');
        sumANNSuccessIncong = sum(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)==1 & SR.arrResults(:,SR.colCongruity)==0,'omitnan');
        sumANNTotalCongTrials = sum(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colCongruity)==1,'omitnan');
        sumANNTotalIncongTrials = sum(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colCongruity)==0,'omitnan');
        sumANNTotalTrials = sumANNTotalCongTrials + sumANNTotalIncongTrials;
        sumANNErrorTOTrials = sum(SR.arrResults(:,SR.colANN)==r & SR.arrResults(:,SR.colSuccess)~=1,'omitnan');
        hitsANNPercentCong = sumANNSuccessCong / sumANNTotalCongTrials * 100;
        hitsANNPercentIncong = sumANNSuccessIncong / sumANNTotalIncongTrials * 100;
        hitsANNPercentSCE = hitsANNPercentCong - hitsANNPercentIncong;

        % Total number of trials included in the RT analysis. Will have error
        % trials.
        sumANNTotalInclTrials = sumANNCongNumClosePhysFar + sumANNCongNumClosePhysClose + sumANNCongNumFarPhysFar + sumANNCongNumFarPhysClose + ...
                           sumANNIncongNumClosePhysFar + sumANNIncongNumClosePhysClose + sumANNIncongNumFarPhysFar + sumANNIncongNumFarPhysClose;

    
        meanANNSCENumDistLarge = abs(meanANNCongNumDistLarge - meanANNIncongNumDistLarge);
        meanANNSCENumDistSmall = abs(meanANNCongNumDistSmall - meanANNIncongNumDistSmall);
        meanANNSCEPhysDistSmall = abs(meanANNCongPhysDistSmall - meanANNIncongPhysDistSmall);
        meanANNSCEPhysDistLarge = abs(meanANNCongPhysDistLarge - meanANNIncongPhysDistLarge);
      
     
        %send results to output file
        % if add fields here then add them to the resultsANNMatrix as well, for
        % ease of interpretation
        fprintf(fileID, formatSpecDtl, ...
            r, sumANNTotalTrials, sumANNErrorTOTrials, sumANNTotalInclTrials, hitsANNPercentCong, hitsANNPercentIncong, hitsANNPercentSCE, ... 
            meanANNCong, meanANNIncong, meanANNSCE, ...
            meanANNNumDistLarge, meanANNNumDistSmall, meanANNPhysDistLarge, meanANNPhysDistSmall, ...
            meanANNCongNumDistLarge, meanANNIncongNumDistLarge, meanANNCongNumDistSmall, meanANNIncongNumDistSmall, meanANNSCENumDistLarge, meanANNSCENumDistSmall, ...
            meanANNCongPhysDistLarge, meanANNIncongPhysDistLarge, meanANNCongPhysDistSmall, meanANNIncongPhysDistSmall, meanANNSCEPhysDistLarge, meanANNSCEPhysDistSmall, ...
            sumANNCongNumFarPhysFar, sumANNCongNumFarPhysClose, sumANNCongNumClosePhysFar, sumANNCongNumClosePhysClose, sumANNIncongNumFarPhysFar, sumANNIncongNumFarPhysClose, sumANNIncongNumClosePhysFar, sumANNIncongNumClosePhysClose, ...
            meanANNCongNumFarPhysFar, meanANNCongNumFarPhysClose, meanANNCongNumClosePhysFar, meanANNCongNumClosePhysClose, ...
            meanANNIncongNumFarPhysFar, meanANNIncongNumFarPhysClose, meanANNIncongNumClosePhysFar, meanANNIncongNumClosePhysClose, ...
            meanANNDist1SizeSmall, meanANNDist1SizeLarge, ...
            meanANNConflictCong, meanANNConflictIncong, meanANNSCEConflict, ...
            meanANNNumDist1, meanANNNumDist2, meanANNNumDist3, meanANNNumDist4, meanANNNumDist5, meanANNNumDist6, meanANNNumDist7, meanANNNumDist8);
    
        % also put results into matrix so can compare LMA to HMA
        resultsANNMatrix = [resultsANNMatrix; damageType r sumANNTotalTrials sumANNErrorTOTrials sumANNTotalInclTrials hitsANNPercentCong hitsANNPercentIncong hitsANNPercentSCE ... 
            meanANNCong meanANNIncong meanANNSCE ...
            meanANNNumDistLarge meanANNNumDistSmall meanANNPhysDistLarge meanANNPhysDistSmall ...
            meanANNCongNumDistLarge meanANNIncongNumDistLarge meanANNCongNumDistSmall meanANNIncongNumDistSmall meanANNSCENumDistLarge meanANNSCENumDistSmall ...
            meanANNCongPhysDistLarge meanANNIncongPhysDistLarge meanANNCongPhysDistSmall meanANNIncongPhysDistSmall meanANNSCEPhysDistLarge meanANNSCEPhysDistSmall ...
            sumANNCongNumFarPhysFar sumANNCongNumFarPhysClose sumANNCongNumClosePhysFar sumANNCongNumClosePhysClose sumANNIncongNumFarPhysFar sumANNIncongNumFarPhysClose sumANNIncongNumClosePhysFar sumANNIncongNumClosePhysClose ...
            meanANNCongNumFarPhysFar meanANNCongNumFarPhysClose meanANNCongNumClosePhysFar meanANNCongNumClosePhysClose ...
            meanANNIncongNumFarPhysFar meanANNIncongNumFarPhysClose meanANNIncongNumClosePhysFar meanANNIncongNumClosePhysClose ...
            meanANNDist1SizeSmall meanANNDist1SizeLarge ...
            meanANNConflictCong meanANNConflictIncong meanANNSCEConflict ...
            meanANNNumDist1 meanANNNumDist2 meanANNNumDist3 meanANNNumDist4 meanANNNumDist5 meanANNNumDist6 meanANNNumDist7 meanANNNumDist8];
    
    end %ANN/participant

    %save resultsANNMatrix to output file so have full results with LMA and HMA
    %and each run. Creates comma delimitered .txt file
    %writematrix(resultsANNMatrix,'resultsANNMatrix');

    % output overall totals (i.e., all ANNS)
    formatSpecTotal = '%s,%d,%d,%d,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%d,%d,%d,%d,%d,%d,%d,%d,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n';
    fprintf(fileID, formatSpecTotal, ...
        'TOTALS:', sumTotalTrials, sumErrorTOTrials, sumTotalInclTrials, hitsPercentCong, hitsPercentIncong, hitsPercentSCE, ...
        meanCong, meanIncong, meanSCE, ...
        meanNumDistLarge, meanNumDistSmall, meanPhysDistLarge, meanPhysDistSmall, ...
        meanCongNumDistLarge, meanIncongNumDistLarge, meanCongNumDistSmall, meanIncongNumDistSmall, meanSCENumDistLarge, meanSCENumDistSmall, ...
        meanCongPhysDistLarge, meanIncongPhysDistLarge, meanCongPhysDistSmall, meanIncongPhysDistSmall, meanSCEPhysDistLarge, meanSCEPhysDistSmall, ...
        sumCongNumFarPhysFar, sumCongNumFarPhysClose, sumCongNumClosePhysFar, sumCongNumClosePhysClose, sumIncongNumFarPhysFar, sumIncongNumFarPhysClose, sumIncongNumClosePhysFar, sumIncongNumClosePhysClose, ...
        meanCongNumFarPhysFar, meanCongNumFarPhysClose, meanCongNumClosePhysFar, meanCongNumClosePhysClose, ...
        meanIncongNumFarPhysFar, meanIncongNumFarPhysClose, meanIncongNumClosePhysFar, meanIncongNumClosePhysClose, ...
        meanDist1SizeSmall, meanDist1SizeLarge, ...
        meanConflictCong, meanConflictIncong, meanSCEConflict, ...
        meanNumDist1, meanNumDist2, meanNumDist3, meanNumDist4, meanNumDist5, meanNumDist6, meanNumDist7, meanNumDist8);
     
    fclose(fileID);

    if (displaySimResults)
        % printed in the order they should occur, e.g. Mean Congruent < Mean
        % Incongruent
        fprintf('\n');
        fprintf('RESULTS SUMMARY: \n');
        if (taskType == 2)
            fprintf('Note: Results for number comparison are stored/displayed in the Congruent field. \n');
        end
        fprintf('Damage Type: %d \n', damageType);
        fprintf('Mean Congruent: %f \n', meanCong);
        fprintf('Mean Incongruent: %f \n', meanIncong);
        fprintf('Mean SCE (I-C): %f \n', meanSCE);
        fprintf('Total timeouts: %d \n', sumTimeouts);
        fprintf('Total errors: %d \n', sumErrors); 
        fprintf('Total %% errors: %1.2f \n', percentErrors);
        fprintf('%% Hits Congruent: %1.2f \n', hitsPercentCong);
        fprintf('%% Hits Incongruent: %1.2f \n', hitsPercentIncong);
        fprintf('%% Hits SCE (C-I): %1.2f \n', hitsPercentSCE);
        fprintf('Mean NumDist Large: %f \n', meanNumDistLarge);
        fprintf('Mean NumDist Small: %f \n', meanNumDistSmall);
        fprintf('Mean PhysDist Small: %f \n', meanPhysDistSmall);
        fprintf('Mean PhysDist Large: %f \n', meanPhysDistLarge);
        fprintf('Mean NumDist 1: %f \n', meanNumDist1);
        fprintf('Mean NumDist 2: %f \n', meanNumDist2);
        fprintf('Mean NumDist 3: %f \n', meanNumDist3);
        fprintf('Mean NumDist 4: %f \n', meanNumDist4);
        fprintf('Mean NumDist 5: %f \n', meanNumDist5);
        fprintf('Mean NumDist 6: %f \n', meanNumDist6);
        fprintf('Mean NumDist 7: %f \n', meanNumDist7);
        fprintf('Mean NumDist 8: %f \n', meanNumDist8);
        if (taskType == 2) % size effect for number comparison only
            fprintf('Mean Size 1 Small: %f \n', meanDist1SizeSmall);
            fprintf('Mean Size 1 Large: %f \n', meanDist1SizeLarge);
        end
        fprintf('Mean Response Conflict Congruent: %f \n', meanConflictCong);
        fprintf('Mean Response Conflict Incongruent: %f \n', meanConflictIncong);
    end

    if (displaySimBarGraphs)
        barGraphNumStroop;
    end
     
end    %original for loop for different types of damage

fclose(fileIDData);

% use resultsANNMAtrix so can get standard error of the mean values,
% and LMA/HMA at same time.

% Note that if values are very slightly different to the numbers
% output on the display of results, it is because of rounding in the
% calculation of the means.

if displayComparisonGraphs    
    barGraphComparisonRT;
end

if plotNDE    
    linePlotNDE;
end
   
% Conflict plot of one incongruent and one congruent stimulus
if CR.plotConflict
    stroopN1 = 1;
    stroopN2 = 2;
    stroopP1 = 8;
    stroopP2 = 2;
    CR.plotTimestepConflict(damageTypeArr, stroopN1, stroopN2, stroopP1, stroopP2);
    stroopN1 = 1;
    stroopN2 = 8;
    stroopP1 = 2;
    stroopP2 = 8;
    CR.plotTimestepConflict(damageTypeArr, stroopN1, stroopN2, stroopP1, stroopP2);
    %save results to outputfile
    writematrix(CR.arrResults,'conflictResults.csv');
end
    
if displaySizeEffect
    barGraphSizeEffect;
end 
         
if displayDifferentNoLearningTrials
    barGraphLearningTrials;
end
    
% speed-accuracy trade-off
if displayChgThreshold
    barGraphChangeThreshold;
end

if displayStats
    statisticsLMAHMA;
end
