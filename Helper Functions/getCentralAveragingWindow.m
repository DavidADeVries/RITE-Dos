function [crossPlaneWindow, inPlaneWindow] = getCentralAveragingWindow(epidDims, averWindowSideLength)
%[crossPlaneWindow, inPlaneWindow] = getCentralAveragingWindow(epidDims, averWindowSideLength)

averSub = floor(averWindowSideLength/2);

crossPlaneHalf = floor(epidDims(1)/2);
inPlaneHalf = floor(epidDims(2)/2);

crossPlaneWindow = (crossPlaneHalf-(averSub-1)) : (crossPlaneHalf+averSub);
inPlaneWindow = (inPlaneHalf-(averSub-1)) : (inPlaneHalf+averSub);

end

