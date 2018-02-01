function dataMask = createMaxMask(data, settings)
% maskEpid = createMaxMask(epidData, settings)   

dataElements = sort(data(:),'descend');

maxRange = ...
    settings.epidShiftCalcNumOverOrUnderSaturatedPixels + 1:...
    settings.epidShiftCalcNumOverOrUnderSaturatedPixels + settings.epidShiftCalcPixelRange + 1;

dataMax = mean(dataElements(maxRange));

dataMask = +(data > abs(dataMax)/2);


end

