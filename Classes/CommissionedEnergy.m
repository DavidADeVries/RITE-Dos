classdef CommissionedEnergy
    % CommissionedEnergy
    % the photon energy for the linac which holds commissioning data such
    % as F, f, etc.
    
    properties
        energyInMeV = 6 % MeV
        
        notes = ''
        
        fieldSizesInCm = 5:5:50 % cm
        phantomWidthsInCm = 5:5:40 % cm
        phantomShiftsInCm = -10:5:10 % cm
        
        tissueMaximumRatios = {} % not from RITE-Dos!        
        commissioningEpidResults = {} % cell array of CommissioningEpidResult
    end
    
    methods
    end
    
end

