function doseConvolution = getDoseConvolution(epidData, mask, gaussianSumCrossPlane, gaussianSumInPlane, tmrRatio, map_F, map_f, epidDims, settings)
%doseConvolution = getDoseConvolution(epidData, mask, gaussianSumCrossPlane, gaussianSumInPlane, tmrRatio, map_F, map_f, epidDims, settings)

% **CROSS-PLANE**
convolutionCrossPlane = zeros(epidDims(2), epidDims(1));

for row=1:epidDims(2)    
    % give them relative weights
    
    profile = epidData(row,:);
    convolutionCrossPlane(row,:) = conv(profile, gaussianSumCrossPlane, 'same');
    
    % Now that I gave correct shape, I must renormalize to the correct height.
    % Do this by finding the midway point along this cross plane profile and
    % renormalize there. But if no points along this row are in the field, then
    % set the whole row to zeros
    
    first = find(mask(row,:), 1 );
    last = find(mask(row,:), 1, 'last');
    mid = first + round((last-first)/2);
    
    if mid > 1
        tempPostConv = convolutionCrossPlane(row,:);
        tempPreConv = epidData(row,:);
        
        delta = settings.patientDoseCalculationAveragingWindowHalfLength;
        convolutionCrossPlane(row,:) = convolutionCrossPlane(row,:) ./ mean(tempPostConv(mid-delta:mid+delta)) .* mean(tempPreConv(mid-delta:mid+delta));  
    else
        convolutionCrossPlane(row,:) = zeros(1, epidDims(1));
    end
       
end

% **IN PLANE**
convolutionInPlane = zeros(epidDims(2), epidDims(1));

for col=1:epidDims(1)
    % give them relative weights
    profile = convolutionCrossPlane(:,col);
    
    convolutionInPlane(:,col) = conv(profile, gaussianSumInPlane, 'same');
    
    % Now that I gave correct shape, I must renormalize to the correct height.
    % Do this by finding the midway point along this cross plane profile and
    % renormalize there.
    
    first = find(mask(:,col), 1 );
    last = find(mask(:,col), 1, 'last');
    mid = first + round((last-first)/4);
    
    if mid > 1
        tempPostConv = convolutionInPlane(:,col);
        tempPreConv = convolutionCrossPlane(:,col);
        
        delta = settings.patientDoseCalculationAveragingWindowHalfLength;
        convolutionInPlane(:,col) = convolutionInPlane(:,col) ./ mean(tempPostConv(mid-delta:mid+delta)) .* mean(tempPreConv(mid-delta:mid+delta));  
    else
        convolutionInPlane(:,col) = transpose(zeros(1, epidDims(2)));
    end
    
end

% **CALCULATE DOSE WITH CONVOLUTION EDGE CORRECTION**
doseConvolution = mask .* convolutionInPlane .* tmrRatio .* map_f ./ map_F;

end

