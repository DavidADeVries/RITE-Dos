classdef CommissionedEnergy
    % CommissionedEnergy
    % the photon energy for the linac which holds commissioning data such
    % as F, f, etc.
    
    properties
        energyInMeV = 6 % MeV
        
        notes = ''
        
        tissueMaximumRatios = {} % not from RITE-Dos!        
        commissioningEpidResults = {} % cell array of CommissioningEpidResult
    end
    
    methods
    end
    
end

