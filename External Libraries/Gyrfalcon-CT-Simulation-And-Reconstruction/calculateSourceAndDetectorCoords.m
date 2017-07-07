function [pointSourceCoords, pointDetectorCoords] = calculateSourceAndDetectorCoords(indices, sourcePositionInM, detectorPositionInM, anglesInDeg, detectorDims, detectorPixelDimsInM)
%function [pointSourceCoords, pointDetectorCoords] = calculateSourceAndDetectorCoords(indices, sourcePositionInM, detectorPositionInM, anglesInDeg, detectorDims, detectorPixelDimsInM)
    
    % pre-allocate
    dims = size(indices);
    numCoords = dims(1);

    pointSourceCoords = zeros(numCoords,3);
    pointDetectorCoords = zeros(numCoords,3);

    % set intial positions
    [sourceAngleInRad, sourceRadius] = cart2pol(sourcePositionInM(1), sourcePositionInM(2));
    [detectorAngleInRad, detectorRadius] = cart2pol(detectorPositionInM(1), detectorPositionInM(2));

    sourceAngleInDeg = sourceAngleInRad * Constants.rad_to_deg;
    detectorAngleInDeg = detectorAngleInRad * Constants.rad_to_deg;

    % imagine source and detector centres are along positive x-axis
    % now, will rotate everything back later
    pointSourceCoords(:,1) = sourceRadius;
    pointSourceCoords(:,3) = 0;

    pointDetectorCoords(:,1) = detectorRadius;
    pointDetectorCoords(:,3) = 0;

    % SOURCE

    % rotate with the scan angle and bring back from x-axis
    [pointSourceCoords(:,1), pointSourceCoords(:,2)] = rotateCoordsAboutOrigin(pointSourceCoords(:,1),pointSourceCoords(:,2), sourceAngleInDeg - anglesInDeg(indices(:,1)));

    % DETECTOR

    % detector placement (for planar 2D detectors only)
    % gives location of detector centre
    
    pointDetectorCoords(:,2) = pointDetectorCoords(:,2) - ( (indices(:,2)-(detectorDims(1)/2)-0.5) * detectorPixelDimsInM(1));
    pointDetectorCoords(:,3) = pointDetectorCoords(:,3) - ( (indices(:,3)-(detectorDims(2)/2)-0.5) * detectorPixelDimsInM(2));
    

    rotateAngles = detectorAngleInDeg;

    rotateAngles = rotateAngles - anglesInDeg(indices(:,1));

    [pointDetectorCoords(:,1), pointDetectorCoords(:,2)] = rotateCoordsAboutOrigin(pointDetectorCoords(:,1), pointDetectorCoords(:,2), rotateAngles);

end

function [x, y] = rotateCoordsAboutOrigin(x, y, anglesInDeg)
    tempX = x;

    x = x .* cosd(anglesInDeg) - y .* sind(anglesInDeg);
    y = y .* cosd(anglesInDeg) + tempX .* sind(anglesInDeg);
end

