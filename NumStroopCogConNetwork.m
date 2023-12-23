% ANN that simulates a numerical Stroop task.
% Adapted by Angela Rose, from multidigit cognitive control network
% written by Stefan Huber (s.huber@iwm-tuebingen.de). 
% Most of the code has been written by Stefan Huber, with minor changes for
% numerical Stroop.

classdef NumStroopCogConNetwork < handle
    
    properties (Constant)
        % values taken from Verguts and Notebaert (2008)
        TAU = 0.75;                      % equals lambda_s in Verguts' script
        lambda_con = 0.8;                % lambda of control unit
        alfa_con = 1; beta_con = 1;      % scale and bias of control unit
        lambda_w = 0.7;                  % lambda of w_ti weights
        beta_input = 0.2;
        
        % modified values to reduce the size of the compatibility effect
        % alfa_wti from 20 to 5
        % irr from 1.1 to 0.5
        alfa_wti = 5; beta_wti = 0.5;   % scale and bias of w_ti weights
        
        % modified values to ensure that maxnstep is not reached
        % have moved to public access so can modify
        %threshold = 0.75;               % threshold of the output activity - original Huber
        maxnstep = 200;         %maximum RT for simulated RT
        
        % learning rate for error adaption of input-to-response weights
        alphaI2R = 0.1;
        
        % response inhibition
        inh = -0.5;      
    end
    
    % public for copy&paste
    properties (Access = public)
        outputTest = cell(3000,27);     % cell array for test values (was a
                                        % matrix in Huber et al.)
        numErrors = 0;                  % number of errors to display while testing
        numTimeouts = 0;                % number of timeouts to display while testing
        threshold = 0.75;               % threshold of the output activity - from Huber but made public so can change
      end
    
    properties (Access = private)
        taskType                        % code for the type of task (1=numerical Stroop, 2=single-digit number comparison)
        numDigits                       % number of digits (integer + decimal)
        numOfIntegerDigits              % number of integer digits
        numOfDecimalDigits              % number of digits after decimal mark
        DCNetworks = DCNetwork();       % digit comparison networks
        numTasks;                       % number of comparison networks (= number of tasks)
        inputVector                     % input layer
        taskVector                      % task nodes
        taskVectorInitial               % initial task nodes
        responseVector = zeros(2,1);    % response layer
        weightsT2I                      % weights task to input
        weightsI2R                      % weights input to response
        weightsInh                      % inhibitory weights
        conflictVector                  % vector of conflict values for each item
        meanConflict = 0.0;             % mean conflict
        mask_wti                        % mask for weightsT2I
        mask_wir                        % mask for weightsI2R
        rel                             % connection weights between comparison layer and response layer
                                        % for relevant dimension
        irr                             % connection weights between comparison layer and response layer
                                        % for irrelevant dimension
        std_noise = 0.1;                % standard for integer numbers
        sign = false;
        unusedVar = 0;                  % an unused variable 
    end
    
    % constructor
    methods (Access = public)
        function NSCCN = NumStroopCogConNetwork(taskType, numberOfIntDigits, numberOfDecDigits, taskVector, rel, irr, setDCWeights, numANN, DCNWeightsI2O_FromFile, trainPairs)
            NSCCN.taskType = taskType;
            NSCCN.numOfIntegerDigits = numberOfIntDigits;
            NSCCN.numOfDecimalDigits = numberOfDecDigits;
            NSCCN.numDigits = numberOfIntDigits + numberOfDecDigits;
            NSCCN.taskVector = taskVector;
            NSCCN.taskVectorInitial = taskVector;
            NSCCN.rel = rel;
            NSCCN.irr = irr;
 
            % Initialise first comparison network weights
            switch setDCWeights
                case 0
                    NSCCN.DCNetworks(1,1).setWeightsToSavedWeights(); % reuse saved weights because it's faster - these are Huber's weights.
                case {1, 2}
                    NSCCN.DCNetworks(1,1).setWeightsFromTraining(trainPairs);
                case {3, 4}
                    NSCCN.DCNetworks(1,1).setWeightsFromExternalFile(numANN, 1, DCNWeightsI2O_FromFile); % reuse saved weights from external file, are different for every single digit network.
                otherwise
                    NSCCN.DCNetworks(1,1).setWeightsToSavedWeights();
            end

            % Initialise remaining comparison network weights. For
            % Numerical Stroop numDigits=2. For single-digit number
            % comparison ie taskType=2, numDigits=1 therefore for loop is
            % not executed.
            for i = 2 : NSCCN.numDigits
                NSCCN.DCNetworks(i,1) = DCNetwork();
                if (i > numberOfIntDigits)
                    % unused code for numerical Stroop (sets weights for
                    % decimal digits)
                    NSCCN.DCNetworks(i,1).setWeightsToSavedWeightsDecimal(); % reuse saved weights because it's faster
                else
                    switch setDCWeights
                        case 0
                            NSCCN.DCNetworks(i,1).setWeightsToSavedWeights(); 
                        case 1
                            NSCCN.DCNetworks(i,1).weightsI2O = NSCCN.DCNetworks(1,1).weightsI2O; % use same weights for both
                        case 2
                            NSCCN.DCNetworks(i,1).setWeightsFromTraining(trainPairs);      % retrain network
                        case {3, 4}
                            NSCCN.DCNetworks(i,1).setWeightsFromExternalFile(numANN, i, DCNWeightsI2O_FromFile); % reuse saved weights from external file
                        otherwise
                            NSCCN.DCNetworks(i,1).setWeightsToSavedWeights(); % Huber: reuse saved weights because it's faster
                    end
                end
            end
            
            NSCCN.numTasks = NSCCN.numDigits;   % previously: Huber added length comparison and sign comparison here
            
            NSCCN.inputVector = zeros(NSCCN.numTasks*2,1);
            NSCCN.weightsT2I = kron(eye(NSCCN.numTasks), ones(2,1))/2;
            
            NSCCN.mask_wti = (NSCCN.weightsT2I > 0);
            NSCCN.weightsI2R = zeros(2,2*NSCCN.numTasks);
            NSCCN.weightsI2R(1:2,1:2) = NSCCN.rel*eye(2);

            for i=2:NSCCN.numTasks
                NSCCN.weightsI2R(1:2,i*2-1:i*2) = NSCCN.irr(i-1,1)*eye(2);
            end
            
            NSCCN.mask_wir = (NSCCN.weightsI2R > 0);
            NSCCN.weightsInh = NSCCN.inh*(ones(2,2) - eye(2));
        end
    end
    
    % public methods
    methods (Access = public)
              
       % tests the network using items from a vector of item file names
       function testListFromFile(NSCCN, fileName, adaptationType, breaks, randomize, numANN, SR, DS, CR)
           for i=1:size(fileName,1)
               if (i == 1)
                   numberPairs = NumStroopCogConNetwork.readItemSetFromFile(fileName(i,:),randomize);
               else
                   numberPairs = [ numberPairs ; NumStroopCogConNetwork.readItemSetFromFile(fileName(i,:),randomize) ];   %#ok<AGROW>
               end
           end
           NSCCN.testList(numberPairs, adaptationType, breaks, numANN, SR, DS, CR);
       end
       
       % resets changes due to adaption of either task nodes or weights
       function resetAdaptation(NSCCN, adaptationType) 
              if (adaptationType == AdaptionTypes.AdaptWeightsT2I)
                  NSCCN.meanConflict = 0;
                  NSCCN.conflictVector = NSCCN.conflictVector * 0;
                  NSCCN.weightsT2I = kron(eye(NSCCN.numTasks), ones(2,1))/2;
              end
                      
              if (adaptationType == AdaptionTypes.AdaptTaskNodes)
                  NSCCN.conflictVector = NSCCN.conflictVector * 0;
                  %commented next line out as function doesn't exist. So
                  %I've guessed what it should do, but haven't tested or
                  %gone over thoroughly, as not used in Stroop
                  %NSCCN.setInitialTaskNodesActivity();
                  NSCCN.taskVector = NSCCN.taskVectorInitial;
              end
       end
        
        % set the initial acitivity of the task nodes
        function setTaskNodesActivity(NSCCN, taskVector)
             NSCCN.taskVector = taskVector;
        end
       
        % set the value of the random Gaussian noise
        function setNoise(NSCCN, std_noise)
             NSCCN.std_noise = std_noise;
        end
        
        % Writes output cell array to comma delimitered text file, 
        % that can be opened as a spreadsheet. 
        % This was an excel spreadsheet in Huber's code, however it has been 
        % changed so the file can be opened with any spreadsheet program.
        function writeItemSetToTextFile(NSCCN, fileID, formatSpecDtl)
            
            [nrows, ~] = size(NSCCN.outputTest);
            
            for r = 1:nrows
                if isempty(NSCCN.outputTest{r,1})
                    break
                end
                fprintf(fileID, formatSpecDtl, NSCCN.outputTest{r,:});
            end
            fprintf('Number of errors for network: %d \n', NSCCN.numErrors);
            fprintf('Number of timeouts for network: %d \n', NSCCN.numTimeouts);
        end
        
    end
    
    methods(Static)
        
        % returns a matrix of items from a txt-file with number pairs in
        % each line separated by an tabulator
        % For numerical Stroop: input file has 4 columns: numerical size
        % number 1 and number 2, then physical size number 1 and number 2,
        % each separated by a space (or could be a tab).
        % For single-digit number comparison: input file has 4 columns:
        % numerical size number 1 and number 2, then physical size number 1
        % and number 2 have been set to zero. Only N1 and N2 are propagated
        % through the network as the parameter
        % numSingleDigitComparisonNetworks=1.
        function itemSet = readItemSetFromFile(fileName, randomize)
            fid = fopen(fileName);
            D = textscan(fid', '%s %s %s %s');
            fclose(fid);
            numberPairs = [D{1} D{2} D{3} D{4}];
            if (randomize)
                itemSet = numberPairs(randperm(size(numberPairs,1)),:);
            else
                itemSet = numberPairs;
            end
            
        end
        
        % returns the correct output for a given number pair (num1 and num2)
        function correctMatrix = getCorrectOutput(num1, num2)
            num1 = str2double(num1);
            num2 = str2double(num2);
            if (num1 > num2)
                correctMatrix = [1 ; 0];
            else
                if (num2 > num1)
                    correctMatrix = [0 ; 1];
                else % should not happen, because networks are not trained to indicate whether numbers are equal
                    correctMatrix = [1 ; 1]; 
                end
            end
        end
        
        % returns the number of digits of the integer and the decimal part
        % of a number
        function lengths = getLengthOfIntAndDecParts( number)
              lengths = zeros(1,2);
              splittedNumber = regexp(number,'\.','split');
              part1 = splittedNumber(1,1);
              lengths(1,1) = length(part1{1});
              
              if(size(splittedNumber,2) == 2)
                  part2 = splittedNumber(1,2);
                  lengths(1,2) = length(part2{1});
              else % if no decimal part
                  lengths(1,2) = 0;
              end
        end
        
        % returns the number of digits of the integer and the decimal part of a number
        function num = getNumberOfEqualDigits(number1, number2)
              n1 = strrep(number1,'.','');
              n2 = strrep(number2,'.','');
              length1 = length(n1);
              length2 = length(n2);
              lengthMin = min(length1,length2);
              count = 0;
              for i=1:lengthMin
                  if(n1(i) == n2(i))
                      count = count + 1;
                  end
              end
              num = count;
        end
        
        % returns 0 for -, and 1 for +
        function signBin = getBinaryCodeForSign(sign)
            signBin = 2;
            if (sign == '-')
                signBin = 0;
            end
            if (sign == '+')
                signBin = 1;
            end
        end
    end
    
    % private methods
    methods (Access = private)
        
          % tests the network using numberPairs as input
          % results are written to outputTest
          function testList(NSCCN, numberPairs, adaptationType, breaks, numANN, SR, DS, CR)
             NSCCN.conflictVector = zeros(1, size(numberPairs, 1));
             breakCount = 1;
             for i=1:size(numberPairs, 1)
                   number1Str = numberPairs(i,1);
                   number2Str = numberPairs(i,2);
                   stroopN1 = str2double(number1Str);
                   stroopN2 = str2double(number2Str);
                   stroopP1 = str2double(numberPairs(i,3));
                   stroopP2 = str2double(numberPairs(i,4)); 
                   
                   %Can input an empirical RT in the input data file to
                   %compare model performance with empirical/other studies.
                   %Not used for numerical Stroop. If use, need to set
                   %which column number the data was in below.
                   rt_emp = -1;
                   %{
                   sizeNumberPairs = size(numberPairs);
                   if(sizeNumberPairs(1,2) == 3)
                      rt_emp = numberPairs(i,3);
                   end
                   %}
    
                   NSCCN.DCNetworks(1,1).setInputActivity(stroopN1, stroopN2);
 
                   if (NSCCN.taskType == 1)
                       NSCCN.DCNetworks(2,1).setInputActivity(stroopP1, stroopP2);
                   end
                   
                   rt = propagateActivity(NSCCN, DS, CR, numANN, stroopN1, stroopN2, stroopP1, stroopP2);
                   if (rt > NSCCN.maxnstep)
                       rt = NaN;
                   end
                   
                   % adaptation
                   if (adaptationType == AdaptionTypes.AdaptWeightsT2I)
                       if (breakCount>1)
                           adaptWeightsT2I(NSCCN, i, breaks(breakCount-1,1));
                       else
                           adaptWeightsT2I(NSCCN, i, 0);
                       end
                   end
                   
                   % not used for Numerical Stroop
                   if (adaptationType == AdaptionTypes.AdaptTaskNodes)
                       adaptTaskNodes(NSCCN, number1Str, number2Str);
                   end
                   
                   NSCCN.writeLineOutputArray(numANN, i, stroopN1, stroopN2, stroopP1, stroopP2, rt_emp, rt, SR);


                   % reset adaptation
                   if (breakCount <= size(breaks,1) && mod(i, breaks(breakCount,1)) == 0)
                       NSCCN.resetAdaptation(adaptationType);
                       breakCount = breakCount + 1;
                   end
             end
          end
       
          
        % output data to cell array (for exporting to text file) to enable
        % output of strings. (Previously, Huber output to matrix so didn't
        % enable strings. For numerical Stroop, changed outputTest from
        % matrix to cell.) If add a field to output file, need to increase
        % cell array size and header/detail format.
        function writeLineOutputArray(NSCCN, numANN, trialNr, stroopN1, stroopN2, stroopP1, stroopP2, rt_emp, rt, SR)
            NSCCN.outputTest{trialNr,1} = numANN;
            NSCCN.outputTest{trialNr,2} = trialNr;
            NSCCN.outputTest{trialNr,3} = stroopN1;
            NSCCN.outputTest{trialNr,4} = stroopN2;
            NSCCN.outputTest{trialNr,5} = stroopP1;
            NSCCN.outputTest{trialNr,6} = stroopP2;
            if (isnan(rt))
                % time out, did not reach threshold
                NSCCN.outputTest{trialNr,7} = 2;
            else
                NSCCN.outputTest{trialNr,7} = (NSCCN.responseVector(1,1) > NSCCN.responseVector(2,1) && stroopN1 > stroopN2) || ...
                                            (NSCCN.responseVector(1,1) < NSCCN.responseVector(2,1) && stroopN1 < stroopN2);
            end
            
            if ((NSCCN.taskType == 1) && (stroopN1 < stroopN2 && stroopP1 < stroopP2) || ...
                (stroopN1 > stroopN2 && stroopP1 > stroopP2)) || (NSCCN.taskType == 2)
                % Congruent trial              
                NSCCN.outputTest{trialNr,8} = 'C';
            else
                % Incongruent trial
                NSCCN.outputTest{trialNr,8} = 'I';
            end
          
            NSCCN.outputTest{trialNr,9} = abs(stroopN1 - stroopN2);
            if (abs(stroopN1 - stroopN2) <= SR.smallDistLimit)
                % Distance effect for numerical size 
                NSCCN.outputTest{trialNr,10} = 'S';
            else              
                NSCCN.outputTest{trialNr,10} = 'L';
            end
            NSCCN.outputTest{trialNr,11} = abs(stroopP1 - stroopP2);
            if (abs(stroopP1 - stroopP2) <= SR.smallDistLimit)
                 % Distance effect for physical size     
                 NSCCN.outputTest{trialNr,12} = 'S';
            else      
                NSCCN.outputTest{trialNr,12} = 'L';
            end
            NSCCN.outputTest{trialNr,13} = rt;
            
            NSCCN.outputTest{trialNr,14} = NSCCN.responseVector(1,1);
            NSCCN.outputTest{trialNr,15} = NSCCN.responseVector(2,1);
            x_acc = -NSCCN.responseVector' * NSCCN.weightsInh * NSCCN.responseVector;
            NSCCN.outputTest{trialNr,16} = x_acc;
            %NSCCN.outputTest{trialNr,17} = ;
            %NSCCN.outputTest{trialNr,18} %for current conflict
            %NSCCN.outputTest{trialNr,19} %for mean conflict
            %NSCCN.outputTest{trialNr,20} = ;
            NSCCN.outputTest{trialNr,21} = NSCCN.weightsT2I(1,1);
            NSCCN.outputTest{trialNr,22} = NSCCN.weightsT2I(2,1);
            if (NSCCN.numDigits > 1)
                NSCCN.outputTest{trialNr,23} = NSCCN.weightsT2I(3,2);
                NSCCN.outputTest{trialNr,24} = NSCCN.weightsT2I(4,2);
            end
            %NSCCN.outputTest{trialNr,25} = ;
            if (isa(rt_emp, 'double') == 1)
                NSCCN.outputTest{trialNr,26} =  rt_emp;
            else
                NSCCN.outputTest{trialNr,26} =  str2double(rt_emp{1});
            end
            
            %This only works for Suarez dataset and is temporary.
            % hardcode calculating size effect here so don't have to do
            % each time in spreadsheet. This code is for input numbers 1,
            % 2, 8, 9, and sets the number size to 1 if it is small numbers
            % and 9 if it is large numbers. Only tests these distances: 1vs
            % 2, 2vs1 and 8vs9, 9vs8. Code should go into a
            % separate function. Also not outputed to outputTest.
            numberSize = 0;
            NSCCN.outputTest{trialNr,27} = '0';
            %only test for 1,2 (set numberSize to 1 and S) and
            % 8,9 (set numberSize to 9 and L)
            if ((stroopN1 == 1) && (stroopN2 == 2)) || ((stroopN1 == 2) && (stroopN2 == 1))
                numberSize = 1;
                NSCCN.outputTest{trialNr,27} = 'S';
            end
            if ((stroopN1 == 8) && (stroopN2 == 9)) || ((stroopN1 == 9) && (stroopN2 == 8))
                numberSize = 9;
                NSCCN.outputTest{trialNr,27} = 'L';
            end
               
            % Put results into matrix to calculate stats at end for all
            % participants.
            SR.arrResultsIdx = SR.arrResultsIdx + 1;
            SR.arrResults(SR.arrResultsIdx,:) = [numANN, trialNr, stroopN1, stroopN2, stroopP1, stroopP2, NSCCN.outputTest{trialNr,7}, NSCCN.outputTest{trialNr,8}=='C', ...
                NSCCN.unusedVar, NSCCN.outputTest{trialNr,9}, NSCCN.outputTest{trialNr,11}, numberSize, NSCCN.outputTest{trialNr,13}, NSCCN.outputTest{trialNr,16}];
            
            % display errors and calc means for testing
            switch NSCCN.outputTest{trialNr,7}
                case 0
                    NSCCN.numErrors = NSCCN.numErrors + 1;
                    fprintf('Error: %s %s %s\n', NSCCN.outputTest{trialNr,8}, ...
                    NSCCN.outputTest{trialNr,10}, NSCCN.outputTest{trialNr,12});
                case 2
                    NSCCN.numTimeouts = NSCCN.numTimeouts + 1;
                    fprintf('Timeout: %s %s %s\n', NSCCN.outputTest{trialNr,8}, ...
                    NSCCN.outputTest{trialNr,10}, NSCCN.outputTest{trialNr,12});
            end
            
        end
        
        % propagates the activity and returns the simulated RT
        function time = propagateActivity(NSCCN, DS, CR, numANN, stroopN1, stroopN2, stroopP1, stroopP2)
            NSCCN.responseVector = NSCCN.responseVector * 0.0; % reset output vector
            for i=1:NSCCN.numDigits
                NSCCN.DCNetworks(i,1).resetOutputLayer();
            end
            NSCCN.inputVector = NSCCN.inputVector * 0.0; % reset input vector 
            time = 0;
            
            startDigit = 1;
            endDigit = NSCCN.numDigits;
            
            saveTaskVector = NSCCN.taskVector;

            % damage at the beginning of each numberPair
            % (This can be moved elsewhere to reduce unnecessary calls, was originally here while
            % testing different types of damage.)
            applyDamage(NSCCN, DS);            
            
            switch DS.damageType
                case 70
                    NSCCN.threshold = 0.65;
                case 71
                    NSCCN.threshold = 0.70;
                case 72
                    NSCCN.threshold = 0.80;
                case 73
                    NSCCN.threshold = 0.85;
            end
            
            while (time <= NSCCN.maxnstep && max(NSCCN.responseVector) < NSCCN.threshold)
                
                nettoActivity = zeros(1,2*NSCCN.numTasks);
                for i=startDigit:endDigit
                    NSCCN.DCNetworks(i,1).propagate();
                    nettoActivity(1,(i*2-1):(i*2)) = NSCCN.DCNetworks(i,1).getOutputLayer();
                end
                                
                %nettoActivity
                
                NSCCN.inputVector = NSCCN.TAU*NSCCN.inputVector + (1-NSCCN.TAU) * (nettoActivity' + NSCCN.beta_input);
                inputVectorGated = NSCCN.inputVector.*(0.7 + NSCCN.weightsT2I * NSCCN.taskVector); 
                inputVectorGated = max(0,inputVectorGated);
                
                % Equation (A2) from Notebaert and Verguts (2008)
                %NSCCN.responseVector = NSCCN.TAU * NSCCN.responseVector + (1-NSCCN.TAU) * (NSCCN.weightsI2R * inputVectorGated + NSCCN.weightsInh * NSCCN.responseVector) + NSCCN.std_noise*randn(2,1);
                NSCCN.responseVector = NSCCN.TAU * NSCCN.responseVector + (1-NSCCN.TAU) * (NSCCN.weightsI2R * inputVectorGated + NSCCN.weightsInh * NSCCN.responseVector);
               
                NSCCN.responseVector = max(0 , NSCCN.responseVector);
                
                
                time = time + 1;
                   
                if (CR.plotConflict)
                    %save amount of conflict (i.e., energy in response layer) at each timestep for conflict graph 
                    CR.arrResultsIdx = CR.arrResultsIdx + 1;
                    x_rtacc = -NSCCN.responseVector' * NSCCN.weightsInh * NSCCN.responseVector;
                    CR.arrResults(CR.arrResultsIdx, :) = [DS.damageType, numANN, stroopN1, stroopN2, stroopP1, stroopP2, time, x_rtacc];
                end
            end
                
            % reset damage
            switch DS.damageType
                case {7, 8, 9, 20}
                    NSCCN.taskVector = saveTaskVector;
                case {70 | 71 | 72 | 73}
                    NSCCN.threshold = 0.75;   %reset threshold back to original
            end
                        
        end
        
        % function applies damage to model weights/activations. This is the
        % only function that sets how much damage to apply/scale. So only
        % need to adjust here. 
        % If add a DamageType here, need to add it to switch statement in
        % function propagateActivity to reset damage.
        function applyDamage(NSCCN, DS)
            switch DS.damageType
                case 0
                    % no damage. 
                    
                % apply damage to activation of task demand units:
                % NSCCN.taskVector
                case 7
                    % scale task demand unit activation for Numerical Size
                    % only
                    scaleFactorTDNumSize = 0.95;
                    NSCCN.taskVector(1,1) = scaleFactorTDNumSize * NSCCN.taskVector(1,1);
                case 20
                    % scale task demand unit activation for Numerical Size
                    % only. Use this in inconjunction with 7 if want to run
                    % 2 HMA at once.
                    scaleFactorTDNumSize = 0.90;
                    NSCCN.taskVector(1,1) = scaleFactorTDNumSize * NSCCN.taskVector(1,1);
                case 8
                    % scale task demand unit activation for Physical size
                    % only
                    scaleFactorTDPhysSize = 0.95;
                    NSCCN.taskVector(2,1) = scaleFactorTDPhysSize * NSCCN.taskVector(2,1);
                case 9
                    % scale task demand unit activation for both numerical
                    % and physical size dimensions
                    scaleFactorTD = 0.95;
                    NSCCN.taskVector = scaleFactorTD * NSCCN.taskVector;    
            end    
        end
        
        % adapation of task-to-input nodes using the algorithm of Verguts
        % and Notebaert (2008)
        function adaptWeightsT2I(NSCCN, trialNr, curBreakPoint)
            x_acc = -NSCCN.responseVector' * NSCCN.weightsInh * NSCCN.responseVector;
            NSCCN.outputTest{trialNr,16} = x_acc;
            curConflictVectorIndex = trialNr - curBreakPoint;
            NSCCN.conflictVector(1,curConflictVectorIndex) = NSCCN.lambda_con *  NSCCN.conflictVector(1,curConflictVectorIndex-(curConflictVectorIndex>1)) + (1-NSCCN.lambda_con) * (NSCCN.alfa_con * x_acc + NSCCN.beta_con);
            NSCCN.meanConflict = (curConflictVectorIndex-1)/curConflictVectorIndex * NSCCN.meanConflict + (1/curConflictVectorIndex)*NSCCN.conflictVector(1,curConflictVectorIndex);
            NSCCN.outputTest{trialNr,18} = NSCCN.conflictVector(1,curConflictVectorIndex); % current conflict
            NSCCN.outputTest{trialNr,19} = NSCCN.meanConflict;
            f = (NSCCN.conflictVector(1,curConflictVectorIndex) - NSCCN.meanConflict)  * NSCCN.inputVector * (NSCCN.taskVector - 0.5)';
            NSCCN.weightsT2I = NSCCN.lambda_w * NSCCN.weightsT2I + (1-NSCCN.lambda_w)*(f * NSCCN.alfa_wti + NSCCN.beta_wti);
            NSCCN.weightsT2I = NSCCN.weightsT2I .* NSCCN.mask_wti;
            NSCCN.weightsT2I = max(0,NSCCN.weightsT2I);
        end
        
        % adaption of task nodes using an error signal
        function adaptTaskNodes(NSCCN, num1, num2)
            % not used for numerical Stroop. If use, need to check logic
            % is correct as it crashes. Whether need to add option for numDigits=1 or use
            % numDigits=2 and input two two-digit numbers.
            delta = (NumStroopCogConNetwork.getCorrectOutput(num1,num2) -  NSCCN.responseVector) * NSCCN.alphaI2R;
            delta_input = delta * NSCCN.inputVector';
            delta_input = delta_input.* NSCCN.mask_wir;
            if (NSCCN.numDigits == 2)
                error_modulation = [delta_input(1,1)+delta_input(2,2) delta_input(1,3)+delta_input(2,4) delta_input(1,5)+delta_input(2,6) delta_input(1,7)+delta_input(2,8)]';
            end
            if (NSCCN.numDigits == 3)
                error_modulation = [delta_input(1,1)+delta_input(2,2) delta_input(1,3)+delta_input(2,4) delta_input(1,5)+delta_input(2,6) delta_input(1,7)+delta_input(2,8) delta_input(1,9)+delta_input(2,10)]';
            end
            if (NSCCN.numDigits == 4)
                error_modulation = [delta_input(1,1)+delta_input(2,2) delta_input(1,3)+delta_input(2,4) delta_input(1,5)+delta_input(2,6) delta_input(1,7)+delta_input(2,8) delta_input(1,9)+delta_input(2,10) delta_input(1,11)+delta_input(2,12)]';
            end
            NSCCN.taskVector = NSCCN.taskVector + error_modulation;
        end
    end
end

