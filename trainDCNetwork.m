% Stand-alone script to train a single-digit number comparison network.
% Script written by Angela Rose (was Porter), which calls methods written by Stefan Huber.

% outout the weights to a (space delimitered) csv file to be loaded into NSCCN
% main code so they are set. This is for speed and repeatability.
saveWeightsToFile = true;

% num ANNs to train. Need to set this value and numTrainDCN will be
% automatically calculated. If not saving the weights to an output file
% then just set this to 1.
numANN = 30;

% Each single digit comparison network runs training once and generates 2
% rows in the output file. Every ANN requires 2 single digit comparison
% networks to be trained (num size and phys size), which equals 4 rows (sets of weights)
% in the output file: for weights into: num size L node,
% num size R node, phys size L node, phys size R node. 
% For the single-digit comparison task that is not numerical Stroop (i.e
% taskType=2), train the networks as per Stroop as when testing the network
% it will just ignore the phys size network.
numTrainDCN = numANN*2;

if saveWeightsToFile
    % each row in file contains 18 weights that connect to one of the nodes
    % in the comparison layer. (First row is weights into left node, second row is weights into
    % right node. So each single digit comparison network
    % training will have 2 rows in this file for the 2 columns in
    % DCN.weightsI2O
    outputFile = 'savedWeightsI2O_30ANN_LR01_G_30000_1.csv';
    fileID = fopen(outputFile, 'w');
    %floating point number with a total of 18 characters (includes minus
    %signs and decimal point, and 15 decimal places. (There are no leading
    %zeroes.)
    formatSpecDtl = '%18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f %18.15f\n';
    rng(1); %have set seed so can rerun and reproduce
end

% set number of training trials. Huber 2016 is 100,000 
numTrainTrials = 30000;

trainPairs = 'G';
   
for i=1:numTrainDCN
    
    DCN = DCNetwork();

    switch trainPairs
        case {'U0', 'U1'}
            % train network using random numbers from a uniform distribution
            DCN.trainRandomList(numTrainTrials, trainPairs)
        case 'G'
            % train network using random numbers from a Google survey
            DCN.trainRandomGoogleList(numTrainTrials)
        otherwise
            %error - need to process/handle this (haven't tested)
            fprintf('Error training comparison network, invalid trainPairs, default to U0: %s \n', trainPairs);
            DCN.trainRandomList(numTrainTrials, 'U0');
    end
            
    % test the network after training
    numTestTrials = 10000;
    DCN.testRandomList(numTestTrials)
    
    if saveWeightsToFile
        fprintf(fileID, formatSpecDtl, DCN.weightsI2O);
    end
end

%output weights to file
if saveWeightsToFile
    fclose(fileID);
end


