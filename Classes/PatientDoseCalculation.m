classdef PatientDoseCalculation
    %PatientDoseCalculation
    
    properties
        % set paths and variables for calculation
        ctDataPath = ''
        epidDataPath = ''
        tpsDataPath = ''
        
        gantryAngle = 0
        numberOfFractions = 1
        
        % calculation results, available for recall
        doseTps
        doseTpsCentralAxisValue
        
        doseNoConvolution
        doseNoConvolutionCentralAxisValue
        
        doseWithConvolution
        doseWithConvolutionCentralAxisValue
        
        doseWithConvolutionAndHornCorrection
        doseWithConvolutionAndHornCorrectionCentralAxisValue
    end
    
    methods
        function [] = setSelectGUI(this, app)
            if isempty(this.ctDataPath)
                app.DoseCalc_CTDataPathEditField.Value = 'None Selected';
            else
                app.DoseCalc_CTDataPathEditField.Value = this.ctDataPath;
            end
            
            if isempty(this.epidDataPath)
                app.DoseCalc_EpidPathEditField.Value = 'None Selected';
            else
                app.DoseCalc_CTDataPathEditField.Value = this.epidDataPath;
            end
            
            app.DoseCalc_GantryAngleEditField.Value = this.gantryAngle;
            app.DoseCalc_NumFractionsEditField.Value = this.numberOfFractions;
            
            % if everything is set, allow for the calculate button to
            % pressed
            if this.isReadyForCalculation()
                app.DoseCalc_CalculateButton.Enable = 'on';
            else
                app.DoseCalc_CalculateButton.Enable = 'off';
            end
        end
        
        function this = createFromSelectGUI(this, app)
            this.gantryAngle = app.DoseCalc_GantryAngleEditField.Value;
            this.numberOfFractions = app.DoseCalc_NumFractionsEditField.Value;
        end
        
        function bool = isReadyForCalculation(this)
            bool = ~isempty(this.ctDataPath) && ~isempty(this.epidDataPath);
        end
        
        function this = calculatePatientDose(this, ctSim, linacAndEpid, settings)
            commissionedEnergy = linacAndEpid.getSelectedCommissionedEnergy();
            
            % params from commissioning
            fieldSizesInCm = commissionedEnergy.fieldSizesInCm;            
            phantomWidthsInCm = commissionedEnergy.phantomWidthsInCm;
            phantomShiftsInCm = commissionedEnergy.phantomShiftsInCm;
            
            tprDepthsInCm = commissionedEnergy.getTprDepthsInCm();
            tprFieldSizesInCm = commissionedEnergy.getTprFieldSizesInCm();
            
            gantryAngle = this.gantryAngle;
            numFractions = this.numberOfFractions;
            
            % Prepare Patient EPIDs and TPS
            patientEpidData = loadEpidData(this.epidDataPath);
                        
            tpsData = dicomread(this.tpsDataPath);
            tpsData = double(tpsData);
            
            tpsInfo = dicominfo(this.tpsDataPath);
            
            tpsData = 100 * tpsData * tpsInfo.(settings.doseGridScalingFieldName) ./ numFractions;
                        
            % Adjusts the EPIDs for left-right and superior-inferior displacement.
            epidMask = createMinMaxMask(patientEpidData, settings);
            tpsMask = createMaxMask(tpsData, settings);
                                    
            epidDimsAtIso = linacAndEpid.getEpidPixelDimsAtIsoInCm();
            
            tpsFieldSize = sqrt(nnz(tpsMask) * prod(epidDimsAtIso));
            epidFieldSize = sqrt(nnz(epidMask) * prod(epidDimsAtIso));
            
            if abs(tpsFieldSize - epidFieldSize) > 1
                question = 'The field sizes of the TPS and EPID images don''t seem to match. Continuing could affect the results. Do you wish to continue?';
                title = 'Error!';
                yes = 'Yes';
                no = 'Abort';
                default = yes;
                
                choice = questdlg(question, title, yes, no, default);
                
                if strcmp(choice, yes)
                    fieldSize = epidFieldSize;
                else
                    error('User abort');
                end
            else
                fieldSize = epidFieldSize;                
            end
            
            % set-up Gaussians for convolution
            
            stDevs = settings.getGaussianCorrectionStDevs();
            
            x = 1:1000;
            mu = 500;
            
            gaussians = gaussDistribution(x, mu, stDevs ./ epidDimsAtIso(1));
                        
            % Get patient w, l, and d map from CT (DAVID)
            
            [WEDsource2iso, WEDiso2epid] = calculateWaterEquivalentDoseWithRayTrace(this.ctDataPath, gantryAngle);
            
            
            wMap = (WEDsource2iso+WEDiso2epid) * Constants.m_to_cm;
            dMap = ((WEDiso2epid-WEDsource2iso) / 2) * Constants.m_to_cm;
                        
            [crossPlaneWindow, inPlaneWindow] = getCentralAveragingWindow(linacAndEpid.epidDims, settings.centralAveragingWindowSideLength);
            
            wMapAver = mean2(wMap(inPlaneWindow, crossPlaneWindow));
                        
            
            % Construct F, f, and TPR maps from w, l, and d
            epidDims = linacAndEpid.epidDims;
            
            phantomWidthIndex_F = round((wMap - ones([epidDims(2) epidDims(1)]) .* (phantomWidthsInCm(1)))/0.1) + 1;
            fieldSizeIndex_F = round((fieldSize - fieldSizesInCm(1)) ./ 0.1) + 1;
            
            outLow = phantomWidthIndex_F < 1;
            outHigh = phantomWidthIndex_F > size(commissionedEnergy.matrix_F, 1);
            phantomWidthIndex_F(outLow) = 1;
            phantomWidthIndex_F(outHigh) = size(commissionedEnergy.matrix_F, 1);
            
            if fieldSizeIndex_F < 1
                fieldSizeIndex_F = 1;
            elseif fieldSizeIndex_F > size(commissionedEnergy.matrix_F, 2)
                fieldSizeIndex_F = size(commissionedEnergy.matrix_F, 2);
            end
            
            
            phantomShiftIndex_f = round((dMap - ones([epidDims(2) epidDims(1)]) * (phantomShiftsInCm(1))) ./ 0.1) + 1;
            fieldSizeIndex_f = round((fieldSize - fieldSizesInCm(1)) ./ 0.1) + 1;
            
            outLow = phantomShiftIndex_f < 1;
            outHigh = phantomShiftIndex_f > size(commissionedEnergy.matrix_F, 1);
            phantomShiftIndex_f(outLow) = 1;
            phantomShiftIndex_f(outHigh) = size(commissionedEnergy.matrix_F, 1);
            
            if fieldSizeIndex_f < 1
                fieldSizeIndex_f = 1;
            elseif fieldSizeIndex_f > size(commissionedEnergy.matrix_F, 2)
                fieldSizeIndex_f = size(commissionedEnergy.matrix_F, 2);
            end
            
            fieldSizeIndexTpr = round((fieldSize - tprFieldSizesInCm(1)) ./ 0.1) +1;
            phantomWidthIndexTpr = round((wMap./2 - tprDepthsInCm(1)) ./ 0.1) +1;
            phantomShiftIndexTpr = round((wMap./2 - dMap - tprDepthsInCm(1)) ./ 0.1) +1;
            
            outLow = fieldSizeIndexTpr < 1;
            outHigh = fieldSizeIndexTpr > size(commissionedEnergy.matrix_Tpr, 2);
            fieldSizeIndexTpr(outLow) = 1;
            fieldSizeIndexTpr(outHigh) = size(commissionedEnergy.matrix_Tpr, 2);
            
            outLow = phantomWidthIndexTpr < 1;
            outHigh = phantomWidthIndexTpr > size(commissionedEnergy.matrix_Tpr, 1);
            phantomWidthIndexTpr(outLow) = 1;
            phantomWidthIndexTpr(outHigh) = size(commissionedEnergy.matrix_Tpr, 1);
            
            outLow = phantomShiftIndexTpr < 1;
            outHigh = phantomShiftIndexTpr > size(commissionedEnergy.matrix_Tpr, 1);
            phantomShiftIndexTpr(outLow) = 1;
            phantomShiftIndexTpr(outHigh) = size(commissionedEnergy.matrix_Tpr, 1);
            
            map_F = commissionedEnergy.matrix_F(phantomWidthIndex_F,fieldSizeIndex_F);
            map_F = reshape(map_F, epidDims(2), epidDims(1));
            
            map_f = commissionedEnergy.matrix_f(phantomShiftIndex_f,fieldSizeIndex_f);
            map_f = reshape(map_f, epidDims(2), epidDims(1));
            
            tpr1 = commissionedEnergy.matrix_Tpr(phantomShiftIndexTpr,fieldSizeIndexTpr);
            tpr1 = reshape(tpr1, epidDims(2), epidDims(1));
            tpr2 = commissionedEnergy.matrix_Tpr(phantomWidthIndexTpr,fieldSizeIndexTpr);
            tpr2 = reshape(tpr2, epidDims(2), epidDims(1));
            
            tprMap = tpr1./tpr2;
            
            % Find map with w and l to weights.
            gaussianWeights = commissionedEnergy.gaussianWeights;
            hornCorrectionMatrix = commissionedEnergy.matrix_hornCorrection;
            
            [~, weightsPhantomWidthIndex] = min(abs(phantomWidthsInCm - wMapAver));
            [~, weightsFieldSizeIndex] = min(abs(fieldSizesInCm - fieldSize));
            weightsInPlane = gaussianWeights(:,(weightsPhantomWidthIndex-1) .* length(fieldSizesInCm) + weightsFieldSizeIndex, 1);
            weightsCrossPlane = gaussianWeights(:,(weightsPhantomWidthIndex-1) .* length(fieldSizesInCm) + weightsFieldSizeIndex, 2);
            hornCorrectionMap = hornCorrectionMatrix(:,:,(weightsPhantomWidthIndex-1)*length(fieldSizesInCm)+weightsFieldSizeIndex);
            
            gaussianSumCrossPlane = sum(weightsCrossPlane.*gaussians) ./ trapz(sum(weightsCrossPlane.*gaussians));
            gaussianSumInPlane = sum(weightsInPlane.*gaussians)/trapz(sum(weightsInPlane.*gaussians));
            
            % Create Patient Dose maps
            % Before convolution
            
            patientDoseNoConvolution = ...
                epidMask .* patientEpidData .* tprMap .* map_f ./ map_F;
            tpsCentralAxisVal = ...
                mean2(tpsData(inPlaneWindow, crossPlaneWindow));
            noConvolutionCentralAxisVal = ...
                (mean2(patientDoseNoConvolution(inPlaneWindow, crossPlaneWindow)) - tpsCentralAxisVal) ./ tpsCentralAxisVal * 100;
            
            %Convolving
            patientDoseConvolution = ...
                getDoseConvolution(patientEpidData, epidMask, gaussianSumCrossPlane, gaussianSumInPlane, tprMap, map_F, map_f);
            convolutionCentralAxisVal = ...
                (mean2(patientDoseConvolution(inPlaneWindow, crossPlaneWindow)) - tpsCentralAxisVal) ./ tpsCentralAxisVal .* 100;
            
            patientDoseConvolutionWithHornCorrection = ...
                patientDoseConvolution .* hornCorrectionMap;
            convolutionWithHornCorrectionCentralAxisVal = ...
                (mean2(patientDoseConvolutionWithHornCorrection(inPlaneWindow, crossPlaneWindow)) - tpsCentralAxisVal) ./ tpsCentralAxisVal .* 100;
            
            % set the results to the object
            this.doseTps = tpsData;
            this.doseTpsCentralAxisValue = tpsCentralAxisVal;
            
            this.doseNoConvolution = patientDoseNoConvolution;
            this.doseNoConvolutionCentralAxisValue = noConvolutionCentralAxisVal;
            
            this.doseWithConvolution = patientDoseConvolution;
            this.doseWithConvolutionCentralAxisValue = convolutionCentralAxisVal;
            
            this.doseWithConvolutionAndHornCorrection = patientDoseConvolutionWithHornCorrection;
            this.doseWithConvolutionAndHornCorrectionCentralAxisValue = convolutionWithHornCorrectionCentralAxisVal;
        end
    end
    
end

