classdef Linac
    % Linac
    % holds the information about a given linac, including EPID
    % specifications, energies, relevant comissioning data, and stored
    % RITE-DOS comissioning data
    
    properties
        name
        
        epidDims = [512 384] % num pixels [xy, z]
        epidPixelDimsInCm = [0.0784 0.0784] % cm
        
        sourceToIsocentreDistanceInCm = 100 % cm
        isocentroToEpidDistanceInCm = 50 % cm
        
        commissionedEnergies = {} % cell array of CommissionedEnergy
    end
    
    methods
    end
    
end

