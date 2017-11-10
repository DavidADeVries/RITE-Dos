classdef Constants
    %Constants
    
    properties (Constant)
        
        
        Use_Mex_Code = true; % set true for C code speed-up
        
        Air_HU_Cutoff = -900; % HU
        
        Source_To_Axis_Distance_In_Cm = 100;
        Axis_To_EPID_Distance_In_Cm = 50;
        
        EPID_Dimensions = [512 384]; % 512 across (x/y), 384 deep (z)
        EPID_Pixel_Dimensions_In_Cm = [0.0784 0.0784];
        
        Round_Off_Error_Bound = 1E-9; %1nm
        Round_Off_Level = 10;
        
        Slash = '/';
        
        RED_Curve_Slopes = [920.85, 1709.81];
        RED_Curve_Intercepts = [-913.48, -1714.97];
        
        % UNITS CONVERSION
        cm_to_m = (1/100);
        m_to_cm = (100/1);
        
        mm_to_m = (1/1000);
        m_to_mm = (1000/1);
        
        deg_to_rad = (pi/180);
        rad_to_deg = (180/pi);
    end
    
    methods
    end
    
end

