classdef CTSim
    %CTSim
    % classes holding the profile for a CT Simulator unit, including the
    % name of the unit, RED curve information, and coordinate description
    
    properties
        name = ''
        
        below0_redCurveIntercept = -913.48 %HU
        below0_redCurveSlope = 920.85 %HU/RED
        
        above0_redCurveIntercept = -1714.97 %HU
        above0_redCurveSlope = 1709.81 %HU/RED
        
        airCutoffInHU = -900 % HU
    end
    
    methods
    end
    
end

