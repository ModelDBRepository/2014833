% GoogleDistribution 
% Class for extracting random numbers from a "Google distribution"
% "Google distribution": frequency of a specific number was determined by a
% Google search
% Author:  Stefan Huber (s.huber@iwm-tuebingen.de)
% Version: 1.0
%
% Code adapted to remove the zero node for numerical Stroop by Angela Rose.

classdef GoogleDistribution < handle
    
    properties (Constant)
        % distribution determined by entering the numbers 0 to 9 into
        % Google search
        freqDistribution = [%110;        % 0         %remove zero from num stroop
                            110;       % 1  
                            95;        % 2
		                    90;        % 3
		                    85;        % 4
		                    85;        % 5
		                    80;        % 6
		                    80;        % 7
		                    75;        % 8
		                    70];       % 9
        sumFreq = sum(GoogleDistribution.freqDistribution);
    end
    
    methods (Static, Access = public)
        % returns a random number from the frequency distribution
        function randomNumber = getRandomNumber()
            randomNumber = -1;
            r = randi([0 GoogleDistribution.sumFreq],1,1);
            cumSum = 0;
            %for i=1:10
            for i=1:9
                cumSum = cumSum + GoogleDistribution.freqDistribution(i,1);
                if (r <= cumSum)
                    %randomNumber = i-1;
                    randomNumber = i;        %remove zero
                    break;
                end;
            end;
        end
    end
    
end