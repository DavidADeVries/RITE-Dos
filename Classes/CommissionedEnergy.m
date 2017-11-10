classdef CommissionedEnergy
    % CommissionedEnergy
    % the photon energy for the linac which holds commissioning data such
    % as F, f, etc.
    
    properties
        energyInMeV = 6 % MeV
        deliveredMU = 100 % MUs
        doseRateInMUsPerMinute = 400 %MU/min
        
        notes = ''
        
        fieldSizesInCm = 5:5:50 % cm
        phantomWidthsInCm = 5:5:40 % cm
        phantomShiftsInCm = -10:5:10 % cm
        
        commissioningEpidDataPath = ''
        commissioningEpidDataDirectoriesCreated = false %T/F, set to T after directories made
        
        tissuePhantomRatioPath = ''
    end
    
    methods
        function name = getName(this)
            name = [...
                num2str(this.energyInMeV),...
                'MeV @ ',...
                num2str(this.doseRateInMUsPerMinute),...
                'MU/min'];
        end
        
        function [] = setGUI(this, app)
            app.Beam_Edit_BeamEnergyEditField.Value = this.energyInMeV;
            app.Beam_Edit_DeliveredMUsEditField.Value = this.deliveredMU;
            app.Beam_Edit_DoseRateEditField.Value = this.doseRateInMUsPerMinute;
            app.Beam_Edit_NotesTextArea.Value = this.notes;
            
            app.Beam_Edit_FieldSizesEditField.Value = getIntervalStringFromValues(this.fieldSizesInCm);
            app.Beam_Edit_PhantomWidthsEditField.Value = getIntervalStringFromValues(this.phantomWidthsInCm);
            app.Beam_Edit_PhantomShiftsEditField.Value = getIntervalStringFromValues(this.phantomShiftsInCm);
            
            % lock down fields if directories already created
            if this.commissioningEpidDataDirectoriesCreated
                app.Beam_Edit_FieldSizesEditField.Editable = 'off';
                app.Beam_Edit_PhantomWidthsEditField.Editable = 'off';
                app.Beam_Edit_PhantomShiftsEditField.Editable = 'off';
                
                app.Beam_Edit_CommissioningDataPathSelectButton.Enable = 'off';
                app.Beam_Edit_CommissioningDataDirectoriesCreateButton.Enable = 'off';
            else
                app.Beam_Edit_FieldSizesEditField.Editable = 'on';
                app.Beam_Edit_PhantomWidthsEditField.Editable = 'on';
                app.Beam_Edit_PhantomShiftsEditField.Editable = 'on';
                
                app.Beam_Edit_CommissioningDataPathSelectButton.Enable = 'on';
                app.Beam_Edit_CommissioningDataDirectoriesCreateButton.Enable = 'on';
            end
            
            % only allow Create Directories if path selected
            if isempty(this.commissioningEpidDataPath)
                app.Beam_Edit_CommissioningDataPathEditField.Value = 'No path selected';
                app.Beam_Edit_CommissioningDataDirectoriesCreateButton.Enable = 'off';
            else                
                app.Beam_Edit_CommissioningDataPathEditField.Value = this.commissioningEpidDataPath;
                
                if ~this.commissioningEpidDataDirectoriesCreated
                    app.Beam_Edit_CommissioningDataDirectoriesCreateButton.Enable = 'on';                
                end
            end
            
            
        end
    end
    
end

