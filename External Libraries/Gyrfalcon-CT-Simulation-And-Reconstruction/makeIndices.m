function indices = makeIndices(numAngles, numDetectorXY, numDetectorZ)
% indices = makeIndices(numAngles, numDetectorXY, numDetectorZ)

numIndices = numAngles * numDetectorXY * numDetectorZ;

[angles, detectXY, detectZ] = ind2sub([numAngles, numDetectorXY, numDetectorZ], 1:numIndices);

indices = [angles' detectXY' detectZ'];


end

