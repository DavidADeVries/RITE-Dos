classdef Linac
    % Linac
    % holds the information about a given linac, including EPID
    % specifications, energies, relevant comissioning data, and stored
    % RITE-DOS comissioning data
    
    properties
        name
        
        epidDims = [512 384] % num pixels [xy, z]
        epidPixelDimsInCm = [0.0784 0.0784] % cm [xy, z]
        
        sourceToIsocentreDistanceInCm = 100 % cm
        isocentreToEpidDistanceInCm = 50 % cm
        
        commissioningMUs
        
        notes = ''
        
        commissionedEnergies = {} % cell array of CommissionedEnergy
    end
    
    methods
    end
    
end

