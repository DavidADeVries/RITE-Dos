function maskEpid = createMinMaxMask(epidData, settings)
% maskEpid = createMinMaxMask(shiftEPIDsF, settings)    

epidElements = sort(epidData(:),'descend');

maxRange = ...
    settings.epidShiftCalcNumOverOrUnderSaturatedPixels + 1:...
    settings.epidShiftCalcNumOverOrUnderSaturatedPixels + settings.epidShiftCalcPixelRange + 1;
minRange = ...
    length(epidElements) - (settings.epidShiftCalcNumOverOrUnderSaturatedPixels + settings.epidShiftCalcPixelRange):...
    length(epidElements) - (settings.epidShiftCalcNumOverOrUnderSaturatedPixels);

epidMax = mean(epidElements(maxRange));
epidMin = mean(epidElements(minRange));
maskEpid = +(epidData > abs(epidMax + epidMin)/2);


end

