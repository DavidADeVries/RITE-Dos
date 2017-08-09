function [waterEquivDose_SourceToIsocentre, waterEquivDose_IsocentreToEPID] = calculateWaterEquivalentDoseWithRayTrace(ctDataPath, gantryAngleInDegrees)
% [waterEquivDose_SourceToIsocentre, waterEquivDose_IsocentreToEPID] = calculateWaterEquivalentDoseWithRayTrace(ctDataPath, gantryAngleInDegrees)

% ******************************
% SET-UP VARIABLES AND CONSTANTS
% ******************************

sadInM = Constants.Source_To_Axis_Distance_In_Cm .* Constants.cm_to_m;
axisToEpidInM = Constants.Axis_To_EPID_Distance_In_Cm .* Constants.cm_to_m;

epidDetectorDims = Constants.EPID_Dimensions; % num of pixels
epidPixelDimsInM = Constants.EPID_Pixel_Dimensions_In_Cm .* Constants.cm_to_m;


% ****************
% LOAD CT DATA SET
% ****************

availableCTFiles = dir(makePath(ctDataPath, 'CT*.dcm'));

numSlices = length(availableCTFiles);

dicomHeader = dicominfo(makePath(ctDataPath, availableCTFiles(1).name));

% load some relevant header info
ctDataSet = zeros(dicomHeader.Rows, dicomHeader.Columns, numSlices);

rescaler = dicomHeader.RescaleIntercept;

xyDim = dicomHeader.ReconstructionDiameter .* Constants.mm_to_m ./ double(dicomHeader.Rows);
zDim = dicomHeader.SliceThickness .* Constants.mm_to_m;

ctVoxelDimsInM = [xyDim, xyDim, zDim];

dicomOriginToTopCornerInM = dicomHeader.ImagePositionPatient .* Constants.mm_to_m;

% read slices
for i=1:numSlices
    readPath = makePath(ctDataPath, availableCTFiles(i).name);
    
    rawData = dicomread(readPath);
    
    % convert to double, so we can math easily
    rawData = double(rawData);
    
    % apply rescaling to get into HU
    rawData = rawData + rescaler;
    
    % put slice into 3D data set
    ctDataSet(:,:,i) = rawData;
end

% ***************************
% APPLY RED CURVE CALIBRATION
% ***************************

equalTo0 = (ctDataSet == 0);
belowCutoff = (ctDataSet <= Constants.Air_HU_Cutoff);
below0 = (ctDataSet < 0);
above0 = (ctDataSet > 0);

redSlopes = Constants.RED_Curve_Slopes;
redIntercepts = Constants.RED_Curve_Intercepts;

% apply calibration
ctDataSet(equalTo0) = 1;

ctDataSet(below0) = (ctDataSet(below0) - redIntercepts(1)) ./ redSlopes(1);
ctDataSet(above0) = (ctDataSet(above0) - redIntercepts(2)) ./ redSlopes(2);

ctDataSet(belowCutoff) = 0; % set below cutoff to zero

% ***************************
% PREPARE RAY TRACE VARIABLES
% ***************************

% axis set-up:
% x : horizontal (perp. to couch)
% y : vertical
% z : horizontal (para. to couch)

% need some information about isocentre from the Eclipse files
planDicomFiles = dir(makePath(ctDataPath, 'RP*.dcm'));

planDicomHeader = dicominfo(makePath(ctDataPath, planDicomFiles(1).name));

dicomOrginToIsocentreInM = planDicomHeader.BeamSequence.Item_1.ControlPointSequence.Item_1.IsocenterPosition .* Constants.mm_to_m;

%calculate location of MATLAB origin with respect to isocentre (0,0,0)

% first apply some corrections for flips, etc.
dicomOrginToIsocentreInM = dicomOrginToIsocentreInM' .* [-1 -1 1];
dicomOriginToTopCornerInM = dicomOriginToTopCornerInM' .* [-1 -1 1];

ctDataLocationInM = dicomOrginToIsocentreInM - dicomOriginToTopCornerInM;

ctDataLocationInM = ctDataLocationInM .* [1 -1 -1];

% set some other values
sourcePositionInM = [0, sadInM, 0]; % this is the "starting" point of the source, gantry angles will rotate it accordingly
detectorPositionInM = [0, -axisToEpidInM, 0]; % again, "starting" point of EPID, rotates with gantry angle

numAngles = 1;

indices = makeIndices(numAngles, epidDetectorDims(1), epidDetectorDims(2));

[pointSourceCoords, pointDetectorCoords] = calculateSourceAndDetectorCoords(...
    indices,...
    sourcePositionInM, detectorPositionInM, gantryAngleInDegrees, epidDetectorDims, epidPixelDimsInM);

[waterEquivDose_SourceToIsocentre, waterEquivDose_IsocentreToEPID] = runWaterEquivalentDoseCalculations(...
    pointSourceCoords, pointDetectorCoords,...
    ctVoxelDimsInM, ctDataLocationInM, ctDataSet,...
    sadInM, axisToEpidInM);

waterEquivDose_SourceToIsocentre = imrotate(fliplr(flipud(reshape(waterEquivDose_SourceToIsocentre, epidDetectorDims))),-90);
waterEquivDose_IsocentreToEPID = imrotate(fliplr(flipud(reshape(waterEquivDose_IsocentreToEPID, epidDetectorDims))),-90);


end
