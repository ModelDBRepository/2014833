% Author: Angela Rose


classdef StroopResults < handle
    
    properties (Constant)
        % if add a constant/column, increase size of arrResults below
        colANN = 1;             % ANN/participant number
        colTrial = 2;           % Trial number
        colN1 = 3;              % Numerical Size 1
        colN2 = 4;              % Numerical Size 2
        colP1 = 5;              % Physical Size 1
        colP2 = 6;              % Physical size 2 
        colSuccess = 7;         % success=1, error=0, timeout=2
        colCongruity = 8;       % congruent=1, incongruent=2
        colUnused = 9;
        colNumDist = 10;         % distance between numerical sizes
        colPhysDist = 11;        % distance between physical sizes
        colNumSize = 12;         % number size: for Suarez dataset of 1, 2, 8, 9 it is 1 for
        %small numbers and 9 for large numbers. Used to work out the
        %problem size effect (temp code). 
        colRT = 13;              % reaction time (RT)
        colConflict = 14;        % amount of response conflict: product of response nodes for a trial
    end
    
    properties (Access = public)
        arrResultsIdx;
        arrResults = NaN(3000,14);        
        smallDistLimit;  % distance between the numbers is small if <=smallDistLimit
    end
    
    %constructor
    methods (Access = public)
        
        function SR = StroopResults(smallDistLimit)
            SR.arrResultsIdx = 0;
            SR.smallDistLimit = smallDistLimit;
        end
    end
    
end
