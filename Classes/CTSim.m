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
        
        notes = ''
    end
    
    properties (Constant)
        varName = 'ctSim';
    end
    
    methods (Static)        
        function this = loadFromFile(filePath)
            data = load(filePath);
            
            this = data.(CTSim.varName);
        end
    end
    
    methods
        function [] = setEditGUI(this, app)
            displayTab(app.CTSimulatorEditTab, app);
            
            app.CTSim_Edit_UnitNameEditField.Value = this.name;
            
            app.CTSim_Edit_NegRed_SlopeEditField.Value = this.below0_redCurveSlope;
            app.CTSim_Edit_NegRed_InterceptEditField.Value = this.below0_redCurveIntercept;
            
            app.CTSim_Edit_PosRed_SlopeEditField.Value = this.above0_redCurveSlope;
            app.CTSim_Edit_PosRed_InterceptEditField.Value = this.above0_redCurveIntercept;
            
            app.CTSim_Edit_AirCutoffEditField.Value = this.airCutoffInHU;
            
            app.CTSim_Edit_NotesTextArea.Value = this.notes;            
        end
        
        function [] = setSelectGUI(this, app)
            hideAllTabs(app);
            
            if isempty(this)
                app.CTSim_UnitNameEditField.Value = 'No Unit Loaded';
                app.CTSim_LoadPathEditField.Value = '';
                
                app.CTSim_EditButton.Enable = 'off';
            else
                app.CTSim_UnitNameEditField.Value = this.name;
                app.CTSim_LoadPathEditField.Value = app.ctSimLoadPath;
                
                app.CTSim_EditButton.Enable = 'on';
            end
        end
        
        function this = createFromEditGUI(this, app)
            this.name = app.CTSim_Edit_UnitNameEditField.Value;
            
            this.below0_redCurveSlope = app.CTSim_Edit_NegRed_SlopeEditField.Value;
            this.below0_redCurveIntercept = app.CTSim_Edit_NegRed_InterceptEditField.Value;
            
            this.above0_redCurveSlope = app.CTSim_Edit_PosRed_SlopeEditField.Value;
            this.above0_redCurveIntercept = app.CTSim_Edit_PosRed_InterceptEditField.Value;
            
            this.airCutoffInHU = app.CTSim_Edit_AirCutoffEditField.Value;
            
            this.notes = app.CTSim_Edit_NotesTextArea.Value;
        end
        
        function [] = saveToFile(this, filePath)
            ctSim = this; % set to correct var name
            
            save(filePath, this.varName);
        end
    end
    
end

