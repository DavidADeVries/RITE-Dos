classdef LinacAndEPID
    % LinacAndEPID
    % holds the information about a given linac, including EPID
    % specifications, energies, relevant comissioning data, and stored
    % RITE-DOS comissioning data
    
    properties
        name = ''
        
        epidDims = [512 384] % num pixels [xy/crossplane, z/inplane]
        epidPixelDimsInCm = [0.0784 0.0784] % cm [xy, z]
        
        epidIntegratedImaging = true % T/F, F for continuous imagiing
        
        epidContinuousImagingFramesPerSecond = 5 % FPS, rate at which EPID frames are taken ONLY FOR CONTINUOUS IMAGING
        epidContinuousImagingFramesPerImage = 1 % number of frames used for averaging ONLY FOR CONTINUOUS IMAGING
        
        sourceToIsocentreDistanceInCm = 100 % cm
        isocentreToEpidDistanceInCm = 50 % cm
                
        notes = ''
        
        commissionedEnergies = {} % cell array of CommissionedEnergy
        
        commissionedEnergyBeingEdited = CommissionedEnergy.empty
        commissionedEnergyBeingEditedIndex = 1 %index for cell array
    end
    
    properties (Constant)
        varName = 'linacAndEpid'
    end
    
    methods (Static)        
        function this = loadFromFile(filePath)
            data = load(filePath);
            
            this = data.(LinacAndEPID.varName);
            
            % default drop down
            this.commissionedEnergyBeingEdited = CommissionedEnergy.empty;
            this.commissionedEnergyBeingEditedIndex = 1;
        end
    end
    
    methods
        function [] = setEditGUI(this, app)
            displayTab(app.LinacEditTab, app);
            
            app.Linac_Edit_UnitNameEditField.Value = this.name;
            app.Linac_Edit_SourceToIsocentreEditField.Value = this.sourceToIsocentreDistanceInCm;
            
            app.Linac_Edit_EpidToIsocentreEditField.Value = this.isocentreToEpidDistanceInCm;
            
            app.Linac_Edit_NumPixelsCrossplaneEditField.Value = this.epidDims(1);
            app.Linac_Edit_NumPixelsInplaneEditField.Value = this.epidDims(2);
            
            app.Linac_Edit_PixelDimsCrossplaneEditField.Value = this.epidPixelDimsInCm(1);
            app.Linac_Edit_PixelDimsInplaneEditField.Value = this.epidPixelDimsInCm(2);
            
            if this.epidIntegratedImaging
                app.Linac_Edit_EpidImagingSettingsButtonGroup.SelectedObject = app.IntegratedButton;
                
                app.FramesPerSecondEditField.Value = this.epidContinuousImagingFramesPerSecond;
                app.FramesPerSecondEditField.Enable = 'off';
                
                app.FramesPerImageEditField.Value = this.epidContinuousImagingFramesPerImage;
                app.FramesPerImageEditField.Enable = 'off';
            else
                app.Linac_Edit_EpidImagingSettingsButtonGroup.SelectedObject = app.ContinuousButton;
                
                app.FramesPerSecondEditField.Value = this.epidContinuousImagingFramesPerSecond;
                app.FramesPerSecondEditField.Enable = 'on';
                
                app.FramesPerImageEditField.Value = this.epidContinuousImagingFramesPerImage;
                app.FramesPerImageEditField.Enable = 'on';
            end
            
            app.Linac_Edit_NotesTextArea.Value = this.notes;
        end
                
        function this = createFromEditGUI(this, app)
            this.name = app.Linac_Edit_UnitNameEditField.Value;
            this.sourceToIsocentreDistanceInCm = app.Linac_Edit_SourceToIsocentreEditField.Value;
            
            this.isocentreToEpidDistanceInCm = app.Linac_Edit_EpidToIsocentreEditField.Value;
            
            this.epidDims(1) = app.Linac_Edit_NumPixelsCrossplaneEditField.Value;
            this.epidDims(2) = app.Linac_Edit_NumPixelsInplaneEditField.Value;
            
            this.epidPixelDimsInCm(1) = app.Linac_Edit_PixelDimsCrossplaneEditField.Value;
            this.epidPixelDimsInCm(2) = app.Linac_Edit_PixelDimsInplaneEditField.Value;
            
            if app.Linac_Edit_EpidImagingSettingsButtonGroup.SelectedObject == app.IntegratedButton
                this.epidIntegratedImaging = true;
                
                this.epidContinuousImagingFramesPerSecond = 1;
                this.epidContinuousImagingFramesPerImage = 1;
            else
                this.epidIntegratedImaging = false;
                
                this.epidContinuousImagingFramesPerSecond = app.FramesPerSecondEditField.Value;
                this.epidContinuousImagingFramesPerImage = app.FramesPerImageEditField.Value;                
            end
            
            this.notes = app.Linac_Edit_NotesTextArea.Value;
        end
        
        function [] = setSelectGUI(this, app)
            hideAllTabs(app);
            
            if isempty(this)
                app.Linac_UnitNameEditField.Value = 'No Unit Loaded';
                app.Linac_LoadPathEditField.Value = '';
                
                app.Linac_EditButton.Enable = 'off';
                
                app.Linac_CommissionedEnergiesDropDown.Items = {};
                app.Linac_CommissionedEnergiesDropDown.Enable = 'off';
                
                app.Linac_CommissionedEnergiesEditButton.Enable = 'off';
                app.Linac_NewCommissionEnergyButton.Enable = 'off';
            else
                app.Linac_UnitNameEditField.Value = this.name;
                app.Linac_LoadPathEditField.Value = app.linacAndEpidLoadPath;
                
                app.Linac_EditButton.Enable = 'on';
                
                this.setNonEmptyCommissionedEnergiesDropDown(app);
                
                app.Linac_NewCommissionEnergyButton.Enable = 'on';
            end
        end
        
        function [] = setNonEmptyCommissionedEnergiesDropDown(this, app)
            numEnergies = length(this.commissionedEnergies);
            
            if numEnergies == 0
                app.Linac_CommissionedEnergiesDropDown.Items = {};
                app.Linac_CommissionedEnergiesDropDown.ItemsData = [];
                
                app.Linac_CommissionedEnergiesDropDown.Enable = 'off';
                
                app.Linac_CommissionedEnergiesEditButton.Enable = 'off';
            else
                items = cell(numEnergies,1);
                
                for i=1:numEnergies
                    items{i} = this.commissionedEnergies{i}.getName();                    
                end
                
                itemsData = 1:numEnergies;
                    
                app.Linac_CommissionedEnergiesDropDown.Items = items;
                app.Linac_CommissionedEnergiesDropDown.ItemsData = itemsData;
                app.Linac_CommissionedEnergiesDropDown.Enable = 'on';
                app.Linac_CommissionedEnergiesDropDown.Value = this.commissionedEnergyBeingEditedIndex;
                
                app.Linac_CommissionedEnergiesEditButton.Enable = 'on';
            end
        end
        
        function [] = saveToFile(this, filePath)
            linacAndEpid = this; % set to correct var name
            
            save(filePath, this.varName);
        end
        
        function this = saveEnergyBeingEdited(this, linacAndEpidLoadPath)
            energies = this.commissionedEnergies;
            
            if this.commissionedEnergyBeingEditedIndex == 0 % is new
                this.commissionedEnergyBeingEdited.addedToLinacAndEpid = true; 
                energies{length(energies)+1} = this.commissionedEnergyBeingEdited;
                this.commissionedEnergyBeingEditedIndex = length(energies);
            else
                energies{this.commissionedEnergyBeingEditedIndex} = this.commissionedEnergyBeingEdited;
            end
            
            % re-sort according to MeV, then dose rate
            sortMatrix = getEnergiesSortMatrix(energies);
            
            [~,index] = sortrows(sortMatrix);
            
            energies = energies(index);
            
            this.commissionedEnergyBeingEditedIndex = index(this.commissionedEnergyBeingEditedIndex);
            this.commissionedEnergies = energies;
            
            this.saveToFile(linacAndEpidLoadPath);
        end
    end
    
end

% HELPER FUNCTIONS

        
function sortMatrix = getEnergiesSortMatrix(energies)

numEnergies = length(energies);

sortMatrix = zeros(numEnergies, 2);

for i=1:numEnergies
    sortMatrix(i,1) = energies{i}.energyInMeV;
    sortMatrix(i,2) = energies{i}.doseRateInMUsPerMinute;
end
end