% Author: Angela Rose


classdef DamageSettings < handle
    
    properties (Constant)
        
    end
    
    properties (Access = public)
        damageType = 0;             % type of damage to apply. 0=no damage
    end
    
    %constructor
    methods (Access = public)
        
        function DS = DamageSettings(damageType)
            DS.damageType = damageType;
        end
    end
    
end
