% DCNetwork 
%
% Artificial neural network for the simulation of the
% comparison of single digit numbers
%
% Author:  Stefan Huber (s.huber@iwm-tuebingen.de)
% Version: 1.0
%
% For numerical Stroop: some minor changes have been made, including adding
% the option to choose the type of training method. Author: Angela Rose.


classdef DCNetwork < handle
   
   properties (Constant)
        ALPHA = 0.01;               % learning rate 
        TAU = 0.01;                 % cascade rate of activation in a trial
        THRESHOLD = 0.75;           % threshold for activation function
        % Huber's saved weights
        % other than decimalsS
        SAVED_WEIGHTS = [-0.511864929228142 4.39272618516079;-0.724322338374192 2.77803059156427;0.00176841426989734 3.22726264972506;1.63543768053811 3.02522330191163;0.811278610158098 1.34327505427213;2.20759783931969 1.51536638099751;1.33504120609633 -0.241520665462216;2.99322799332285 -0.0996751717135838;2.89411652899791 -0.334236628835027;4.42060559891104 -0.785628038504714;3.79837236358670 -0.870777896644516;4.19367664194421 -0.0424334235584019;3.36917522197439 0.782453912512456;2.46255368411295 1.06376694144714;1.66670827248468 1.52276504448384;1.18145243490844 2.02458322600946;1.09237602341207 2.51717615997486;0.0720739423750520 2.32120452181259;-0.437315757860684 3.98194440199658;-1.05025975550086 3.49141796693560;];
        % zero higher priority
        SAVED_WEIGHTS_Decimal = [-1.10967651429135 5.71441611112066;-0.426791163090014 3.89825235159990;-0.245671885889232 3.01217497332500;1.04709541399589 2.91818748427143;2.10460457412000 2.56789142071137;2.26123114756907 1.95567574327179;2.77684783760107 1.29404601590733;4.26485498853246 1.02411226894145;3.49151377669695 -0.810200963160015;3.93747825853358 -1.13999213579980;5.57904771984225 -0.656448429320572;5.22868846975300 0.623637023834364;3.98284365689981 1.07550862069857;2.75880620694170 0.540112561414901;2.62652004004480 1.98731956131432;1.92814351157943 2.54007857515607;0.937594421447878 3.27700034098162;1.31609821850266 3.80067595859943;-0.836561282568751 3.30992955758938;-1.02898275260240 4.34033555033896];
   end
    
   properties (Access = public)  
       outputTest = zeros(100,6);   % output matrix
       %{
       %format of outputTest:
       col 1: input number 1
       col 2: input number 2
       col 3: output/actual activation left node
       col 4: output/actual activation right node
       col 5: reaction time (rt)
       col 6: 1 (i.e. true) if successful trial - compared numbers correctly
              0 (i.e. false) if unsuccessful trial
       %}
   end
   
   properties (Access = public)
                                    % these have been changed to remove
                                    % the zero node.
       inputLayer                   % input vecotor for two digits (10*2, 1)
                                    % digits: range from 0 to 9
       outputLayer = zeros(1,2);    % output vector
       weightsI2O                   % weights from input to output layer(10*2, 2)   
   end
   
   methods (Access = public)
       
       % constructor
       function DCN = DCNetwork()
           %remove zero node: have 18 nodes instead of 20
           %DCN.inputLayer = zeros(2*10,1);
           DCN.inputLayer = zeros(2*9,1);
           outSize = size(DCN.outputLayer);
           %DCN.weightsI2O = rand(2*10, outSize(1,2))*2-1;
           DCN.weightsI2O = rand(2*9, outSize(1,2))*2-1; 
       end
       
       % sets input-to-output weights to saved weights
       function setWeightsToSavedWeights(DCN)
           DCN.weightsI2O = DCN.SAVED_WEIGHTS;
       end
       
       % sets input-to-output weights to saved weights
       function setWeightsToSavedWeightsDecimal(DCN)
           DCN.weightsI2O = DCN.SAVED_WEIGHTS_Decimal;
       end
       
       % sets input-to-output weights
       function setWeightsI2O(DCN, weightsI2O)
           DCN.weightsI2O = weightsI2O;
       end
       
       % gets input-to-output weights
       function weightsI2O = getWeightsI2O(DCN)
           weightsI2O = DCN.weightsI2O;
       end
       
       % sets input activity for a pair of digits
       function setInputActivity (DCN,digit1, digit2)
           if (digit1 ~= digit2)
               DCN.inputLayer = [DCN.calcActivityVector(digit1) ; DCN.calcActivityVector(digit2)];
           else
               %DCN.inputLayer = zeros(2*10,1);
               DCN.inputLayer = zeros(2*9,1);
           end;
       end
       
       function setWeightsFromExternalFile(DCN, numANN, numDCNetwork, DCNWeightsI2O_FromFile)
           switch numDCNetwork
               case 1
                   DCN.weightsI2O = DCNWeightsI2O_FromFile(1:18,4*numANN-3:4*numANN-2);
               case 2
                   DCN.weightsI2O = DCNWeightsI2O_FromFile(1:18,4*numANN-1:4*numANN);
           end
       end

       
       % train network and set weights
       function setWeightsFromTraining(DCN, trainPairs)
           outSize = size(DCN.outputLayer);
           %DCN.weightsI2O = rand(2*10, outSize(1,2))*2-1;  %initialise weights
           DCN.weightsI2O = rand(2*9, outSize(1,2))*2-1;  %initialise weights

           numTrainTrials = 100000;

           switch trainPairs
               case {'U0', 'U1'}
                   % train network using random numbers from a Uniform distribution
                   DCN.trainRandomList(numTrainTrials, trainPairs);
               case 'G'
                   % train network using random numbers from a Google survey
                   trainRandomGoogleList(DCN, numTrainTrials);
               otherwise
                   % error
                   fprintf('Error training comparison network, invalid trainPairs, default to U0: %s \n', trainPairs);
                   DCN.trainRandomList(numTrainTrials, 'U0');
           end
           
           % test the network after training
           numTestTrials = 10000;
           testRandomList(DCN, numTestTrials);
           %DCN.weightsI2O          %display weights for debugging

       end
       
       % trains the network using randomly generated single-digit pairs (from a uniform distribution)
       % it is ensured that digits are different
       function trainRandomList(DCN, numItems, trainPairs)
           for i=1:numItems
               if (trainPairs == 'U0')
                   % weight all numbers evenly
                   %digit1 = randi(10)-1;
                   %digit2 = randi(10)-1;
                   digit1 = randi(9);
                   digit2 = randi(9);
                   while (digit1 == digit2)
                       %digit2 = randi(10)-1;
                       digit2 = randi(9);
                   end
               end
               %training by U1 will not happen when the zero node removed
               if (trainPairs == 'U1')
                   % weight zero more
                   digit1 = randi(11)-2;
                   digit2 = randi(11)-2;
                   if (digit1 == -1)
                       digit1 = 0;
                   end
                   if (digit2 == -1)
                       digit2 = 0;
                   end
                   while (digit1 == digit2)
                       digit2 = randi(10)-2;
                       if (digit2 == -1)
                           digit2 = 0;
                       end
                   end;
               end
               setInputActivity(DCN, digit1, digit2);
               propagateActivity(DCN);
               adaptWeightsDelta(DCN, digit1, digit2);
               %{
               if (i > 0 && mod(i,numItems/10) == 0)
                   i %#ok<NOPRT>
               end;
               %}
           end;
       end
       
       % trains the network using randomly generated single-digit number pairs (from a Google distribution)
       % it is ensured that digits are different
       function trainRandomGoogleList(DCN, numItems)
           %DCN.weightsI2O          %display weights for debugging
           for i=1:numItems
               digit1 = GoogleDistribution.getRandomNumber();
               digit2 = GoogleDistribution.getRandomNumber();
               while (digit1 == digit2)
                   digit2 = GoogleDistribution.getRandomNumber();
               end;
               setInputActivity(DCN, digit1, digit2);
               propagateActivity(DCN);
               adaptWeightsDelta(DCN, digit1, digit2);
               %{
               %display for debugging
               if (i >= 99950)
                   i
                   DCN.weightsI2O
               end;
               %}
               %{
               if (i > 0 && mod(i,numItems/10) == 0)
                   %i %#ok<NOPRT>
                   %DCN.weightsI2O
               end;
               %}
               
           end;
       end
       
       % tests the network using randomly generated number pairs (from a uniform distribution)
       % results are written to outputTest
       function testRandomList(DCN, numItems)
           numErrors = 0;   %initialise error count
           for i=1:numItems
               %digit1 = randi(10)-1;
               %digit2 = randi(10)-1;
               digit1 = randi(9);
               digit2 = randi(9);
               while (digit1 == digit2)
                   %digit2 = randi(10)-1;
                   digit2 = randi(9);
               end;
               DCN.outputTest(i,1) = digit1;
               DCN.outputTest(i,2) = digit2;
               setInputActivity(DCN, digit1, digit2);
               rt = propagateActivity(DCN);
               DCN.outputTest(i,3) = DCN.outputLayer(1,1);
               DCN.outputTest(i,4) = DCN.outputLayer(1,2);
               DCN.outputTest(i,5) = rt;
               DCN.outputTest(i,6) = (DCN.outputLayer(1,1) > DCN.outputLayer(1,2) && digit1 > digit2) || ...
                                        (DCN.outputLayer(1,1) < DCN.outputLayer(1,2) && digit1 < digit2);
               %report if errors in testing
               if (~DCN.outputTest(i,6))
                   numErrors = numErrors + 1;
                   fprintf('Comparison network testing error - unsuccessful trial: %d, compare: %d and %d \n', i, digit1, digit2);
               end;
           end;
           fprintf('Comparison network testing - number of errors out of %d trials: %d \n', numItems, numErrors);
       end
       
      % propagates the activity once
      % called when testing the network (and not when training)
      function propagate(DCN)
           newActivity = DCN.inputLayer'*DCN.weightsI2O;
           DCN.outputLayer = DCN.outputLayer*(1-DCN.TAU) + newActivity*DCN.TAU;
           inhMatrix = [DCN.outputLayer(1,2) * -2  DCN.outputLayer(1,1) * -2];
           DCN.outputLayer = DCN.outputLayer + inhMatrix;
           % DCN.outputLayer = DCN.outputLayer + rand()*0.005;    %Huber  
           DCN.outputLayer = 1 ./ (1 + exp(-2*DCN.outputLayer));  
      end
       
      % returns the output layer activity
      function outputActivity = getOutputLayerActivity(DCN)
          outputActivity = DCN.outputLayer;
          if (outputActivity(1,1) > DCN.THRESHOLD)
              outputActivity(1,1) = 1;
          else
              outputActivity(1,1) = 0;
          end;
          if (outputActivity(1,2) > DCN.THRESHOLD)
              outputActivity(1,2) = 1;
          else
              outputActivity(1,2) = 0;
          end;
      end
      
      % returns the output layer
      function outputLayer = getOutputLayer(DCN)
          outputLayer = DCN.outputLayer;
      end
      
      % resets the output layer
      function resetOutputLayer(DCN)
          DCN.outputLayer = zeros(1,2);
      end
      
   end
   
   methods (Access = private)
       
      % sets the response of threshold reached to 1
      function setResponse(DCN)
          if (DCN.outputLayer(1, 1) > DCN.THRESHOLD)
              DCN.outputLayer(1, 1) = 1;
          end;
          if (DCN.outputLayer(1, 2) > DCN.THRESHOLD)
              DCN.outputLayer(1, 2) = 1;
          end;
      end
      
      % changes weights according to the delta rule
      function adaptWeightsDelta(DCN, digit1, digit2)
          f_derOutput = DCN.outputLayer.*(ones(1,2) - DCN.outputLayer); % first derivate of sigmoid
          delta = DCN.inputLayer*(f_derOutput.*(DCN.getCorrect(digit1,digit2) - (DCN.outputLayer))*DCN.ALPHA);
          DCN.weightsI2O = DCN.weightsI2O + delta;
      end
      
      % propagates the activity and returns the simulated RT
      % called when training the network (and not while testing)
      function rt = propagateActivity(DCN)
           DCN.outputLayer = zeros(1,2);
           rt = 0;
           while(DCN.outputLayer(1,1) < DCN.THRESHOLD && DCN.outputLayer(1,2) < DCN.THRESHOLD && rt < 100)
               newActivity = DCN.inputLayer'*DCN.weightsI2O;
               DCN.outputLayer = DCN.outputLayer*(1-DCN.TAU) + newActivity*DCN.TAU;
               inhMatrix = [DCN.outputLayer(1,2) * -2  DCN.outputLayer(1,1) * -2];
               DCN.outputLayer = DCN.outputLayer + inhMatrix;
               %DCN.outputLayer = DCN.outputLayer + rand()*0.005; %Huber
               DCN.outputLayer = 1 ./ (1 + exp(-2*DCN.outputLayer));               
               rt = rt + 1;
           end;
      end
   end
   
   methods(Static, Access = private)
       % calculates the activity vector for a digit
       function activityVector = calcActivityVector(digit)
          %remove zeroes
          %{ 
          activityVector = zeros(10,1);
           for i=1:10
               activityVector(i,1) = exp(-10*abs(i-(digit+1)));
           end
          %}
          activityVector = zeros(9,1);
          for i=1:9
               activityVector(i,1) = exp(-10*abs(i-digit));
          end;
       end
       
       % returns the correct output vector for a number pair digit1 and
       % digit2
       function correctMatrix = getCorrect(digit1, digit2)
           if (digit1 > digit2)
               correctMatrix = [1 0];
           end
           if (digit1 < digit2)
               correctMatrix = [0 1];
           end
       end
   end
   
end