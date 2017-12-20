classdef Settings
    %Settings
    
    properties
        ctSimDefaultPath = 'C:\'
        linacDefaultPath = 'C:\'
        
        epidDicomDefaultPath = 'C:\'
        treatmentPlanningDefaultPath = 'C:\'
                
        doseGridScalingFieldName = 'DoseGridScaling'
        centralAveragingWindowSideLength = 8
        interpolationGridSpacingForCommissioningInCm = 0.1
    end
    
    properties (Constant)
        filePath = 'User Settings.mat'
        varName = 'settings'
    end
    
    methods (Static)
        function settings = loadFromFile()
            try
                data = load(Settings.filePath);
                settings = data.(Settings.varName);
            catch e % if doesn't exist make it so
                settings = Settings;
                
                settings.saveToFile();
            end            
            
        end
    end
       
    methods
        function [] = saveToFile(this)
            settings = this; %make proper var name
            
            save(this.filePath, this.varName);
        end
        
        function [] = setGUI(this, app)
            displayTab(app.SettingsTab, app);
            
            app.Settings_CTSimPathEditField.Value = this.ctSimDefaultPath;
            app.Settings_LinacPathEditField.Value = this.linacDefaultPath;
            
            app.Settings_EpidDicomPathEditField.Value = this.epidDicomDefaultPath;
            app.Settings_TpsDataPathEditField.Value = this.treatmentPlanningDefaultPath;
        end
    end
    
end

