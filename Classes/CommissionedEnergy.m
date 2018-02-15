classdef CommissionedEnergy
    % CommissionedEnergy
    % the photon energy for the linac which holds commissioning data such
    % as F, f, etc.
    
    properties
        energyInMeV = 6 % MeV
        deliveredMU = 100 % MUs
        doseRateInMUsPerMinute = 400 %MU/min
        
        notes = ''
        
        fieldSizesInCm = 5:5:20 % cm
        phantomWidthsInCm = 5:5:40 % cm
        
        phantomShiftsInCm = -10:5:10 % cm
        phantomWidthForShiftsInCm = 20 %cm
        
        commissioningDataPath = ''
        commissioningDataDirectoriesCreated = false %T/F, set to T after directories made
        
        addedToLinacAndEpid = false %T/F, set to T after being first saved
        
        tissuePhantomRatioPath = ''
        tissuePhantomRatioData = [];
        
        % commissioning results
        matrix_F = []
        matrix_f = []
        matrix_Tpr = []
        matrix_hornCorrection = []
        gaussianWeights = []
    end
    
    methods
        function name = getName(this)
            name = [...
                num2str(this.energyInMeV),...
                'MeV @ ',...
                num2str(this.doseRateInMUsPerMinute),...
                'MU/min'];
        end
              
        function [] = setEditGUI(this, app)            
            displayTab(app.EnergyEditTab, app);
            
            app.Beam_Edit_BeamEnergyEditField.Value = this.energyInMeV;
            app.Beam_Edit_DeliveredMUsEditField.Value = this.deliveredMU;
            app.Beam_Edit_DoseRateEditField.Value = this.doseRateInMUsPerMinute;
            app.Beam_Edit_NotesTextArea.Value = this.notes;
            
            app.Beam_Edit_FieldSizesEditField.Value = getIntervalStringFromValues(this.fieldSizesInCm);
            app.Beam_Edit_PhantomWidthsEditField.Value = getIntervalStringFromValues(this.phantomWidthsInCm);
            
            app.Beam_Edit_PhantomShiftsEditField.Value = getIntervalStringFromValues(this.phantomShiftsInCm);
            app.Beam_Edit_PhantomWidthForShiftsEditField.Value = this.phantomWidthForShiftsInCm;
            
            % lock down fields if directories already created
            if this.commissioningDataDirectoriesCreated
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
            if isempty(this.commissioningDataPath)
                app.Beam_Edit_CommissioningDataPathEditField.Value = 'No path selected';
                app.Beam_Edit_CommissioningDataDirectoriesCreateButton.Enable = 'off';
            else                
                app.Beam_Edit_CommissioningDataPathEditField.Value = this.commissioningDataPath;
                
                if ~this.commissioningDataDirectoriesCreated
                    app.Beam_Edit_CommissioningDataDirectoriesCreateButton.Enable = 'on';                
                end
            end
            
            % only allow Load if TPR path is selected
            
            if isempty(this.tissuePhantomRatioPath)
                app.Beam_Edit_TprDataPathEditField.Value = 'No file selected';
                app.Beam_Edit_TprDataLoadButton.Enable = 'off';
            else
                app.Beam_Edit_TprDataPathEditField.Value = this.tissuePhantomRatioPath;
                app.Beam_Edit_TprDataLoadButton.Enable = 'on';
            end
            
            % only allow commissioning calculation if directories are
            % created (assume they are filled), and a TPR data file is
            % chosen
            if this.commissioningDataDirectoriesCreated && ~isempty(this.tissuePhantomRatioData)
                app.Beam_Edit_CommissioningCalculateAndSaveButton.Enable = 'on';
            else
                app.Beam_Edit_CommissioningCalculateAndSaveButton.Enable = 'off';
            end
            
            % only allow deletion actually saved to linac
            if this.addedToLinacAndEpid
                app.Beam_Edit_RemoveButton.Enable = 'on';
            else
                app.Beam_Edit_RemoveButton.Enable = 'off';
            end
        end
               
              
        function this = createFromEditGUI(this, app)            
            displayTab(app.EnergyEditTab, app);
            
            this.energyInMeV = app.Beam_Edit_BeamEnergyEditField.Value;
            this.deliveredMU = app.Beam_Edit_DeliveredMUsEditField.Value;
            this.doseRateInMUsPerMinute = app.Beam_Edit_DoseRateEditField.Value;
            this.notes = app.Beam_Edit_NotesTextArea.Value;
            
            this.fieldSizesInCm = getValuesFromIntervalString(app.Beam_Edit_FieldSizesEditField.Value);
            this.phantomWidthsInCm = getValuesFromIntervalString(app.Beam_Edit_PhantomWidthsEditField.Value);
            
            this.phantomShiftsInCm = getValuesFromIntervalString(app.Beam_Edit_PhantomShiftsEditField.Value);
            this.phantomWidthForShiftsInCm = app.Beam_Edit_PhantomWidthForShiftsEditField.Value;
        end
        
        function this = createCommissioningDataDirectories(this)
            this.createEpidDirectoriesForSmallF();
            this.createEpidAndTpsDirectoriesForBigF();
            
            this.commissioningDataDirectoriesCreated = true;
        end
        
        function [] = createEpidDirectoriesForSmallF(this)
            newFolder = Constants.SMALL_F_EPID_DIRECTORY;
            mkdir(this.commissioningDataPath, newFolder);
            
            writePath = makePath(this.commissioningDataPath, newFolder);
            
            w = this.phantomWidthForShiftsInCm;
                        
            for l_i=1:length(this.fieldSizesInCm)
                l = this.fieldSizesInCm(l_i);
                
                for d_i=1:length(this.phantomShiftsInCm)
                    d = this.phantomShiftsInCm(d_i);
                    
                    mkdir(writePath, makeDataFolderName(l, w, d));
                end
            end
        end
        
        function [] = createEpidAndTpsDirectoriesForBigF(this)
            epidFolder = Constants.BIG_F_EPID_DIRECTORY;
            mkdir(this.commissioningDataPath, epidFolder);            
            epidPath = makePath(this.commissioningDataPath, epidFolder);
            
            tpsFolder = Constants.BIG_F_TPS_DIRECTORY;
            mkdir(this.commissioningDataPath, tpsFolder);            
            tpsPath = makePath(this.commissioningDataPath, tpsFolder);
            
            d = 0; % no shifts for Big F
                        
            for l_i=1:length(this.fieldSizesInCm)
                l = this.fieldSizesInCm(l_i);
                
                for w_i=1:length(this.phantomWidthsInCm)
                    w = this.phantomWidthsInCm(w_i);
                    
                    mkdir(epidPath, makeDataFolderName(l, w, d));
                    mkdir(tpsPath, makeDataFolderName(l, w, d));
                end
            end
        end
        
        function this = loadTissuePhantomRatioData(this)
            data = csvread(this.tissuePhantomRatioPath);
            
            this.tissuePhantomRatioData = data;
        end
        
        function fieldSizes = getTprFieldSizesInCm(this)
            fieldSizes = this.tissuePhantomRatioData(1,2:end);
        end
        
        function depths = getTprDepthsInCm(this)
            depths = this.tissuePhantomRatioData(2:end,1);
            depths = depths';
        end
        
        function data = getTprData(this)
            data = this.tissuePhantomRatioData(2:end,2:end);
        end
        
        function path = getSmallFEpidPath(this)
            path = makePath(this.commissioningDataPath, Constants.SMALL_F_EPID_DIRECTORY);
        end
        
        function path = getBigFEpidPath(this)
            path = makePath(this.commissioningDataPath, Constants.BIG_F_EPID_DIRECTORY);
        end
        
        function path = getBigFTpsPath(this)
            path = makePath(this.commissioningDataPath, Constants.BIG_F_TPS_DIRECTORY);
        end
                
        function this = commissionEnergy(this, linacAndEpid, appSettings)
            % load-up EPID data
            [tpsValues, epidData_F, epidData_f] = EPIDgen(...
                this.getBigFTpsPath, this.getBigFEpidPath(), this.getSmallFEpidPath(),...
                linacAndEpid.epidDims,...
                this.phantomWidthsInCm, this.fieldSizesInCm,...
                this.phantomShiftsInCm, this.phantomWidthForShiftsInCm,...
                appSettings);
            
            % calculate F and f matrices
            mat_F = makeBigF(...
                tpsValues, epidData_F,...
                this.phantomWidthsInCm, this.fieldSizesInCm,...
                linacAndEpid.epidDims, appSettings);
            
            mat_f = makeSmallf(...
                epidData_f,...
                this.fieldSizesInCm, this.phantomShiftsInCm,...
                linacAndEpid.epidDims, appSettings);
            
            % interpolate matrices
            [matInt_F, matInt_f, matInt_Tpr] = InterpMatrices(...
                mat_F, mat_f,...
                this.phantomWidthsInCm, this.fieldSizesInCm, this.phantomShiftsInCm,...
                this.getTprData(), this.getTprDepthsInCm(), this.getTprFieldSizesInCm(),...
                appSettings.interpolationGridSpacingForCommissioningInCm);
            
            % find Gaussian weights
            [ws_in, ws_cr, ~, mat_hornCorr] = makeGaussianCorr(...
                tpsValues, epidData_F, matInt_F,...
                linacAndEpid.epidDims, linacAndEpid.getEpidPixelDimsAtIsoInCm,...
                this.fieldSizesInCm, this.phantomWidthsInCm,...
                appSettings);
            weights = cat(3 ,ws_in ,ws_cr);
            
            % add to commissioned energy
            this.matrix_F = matInt_F;
            this.matrix_f = matInt_f;
            this.matrix_Tpr = matInt_Tpr;
            this.matrix_HornCorrection = mat_hornCorr;
            this.gaussianWeights = weights;            
        end
        
    end
    
end

