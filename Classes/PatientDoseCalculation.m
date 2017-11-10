classdef PatientDoseCalculation
    %PatientDoseCalculation
    
    properties
        gantryAngle = 0
        numberOfFractions = 1
    end
    
    methods
        function [] = setSelectGUI(this, app)
            app.DoseCalc_CTDataPathEditField.Value = 'None Selected';
            app.DoseCalc_EpidPathEditField.Value = 'None Selected';
            
            app.DoseCalc_GantryAngleEditField.Value = this.gantryAngle;
            app.DoseCalc_NumFractionsEditField.Value = this.numberOfFractions;
            
            app.DoseCalc_CalculateButton.Enable = 'off';           
        end
    end
    
end

