function mat_f = makeSmallf(epidData_f, l_s, d_s, epidDims, settings)
%mat_f = makeSmallf(epidData_f, l_s, d_s, epidDims, settings)

% Gets the central axis mean and arranges it in a useful way for the next
% step.
lLen = length(l_s);
dLen = length(d_s);

[crossPlaneWindow, inPlaneWindow] = getCentralAveragingWindow(...
    epidDims, settings.centralAveragingWindowSideLength);

epid_CAX = mean(mean(epidData_f(inPlaneWindow, crossPlaneWindow, :)));
epid_CAX = squeeze(permute(epid_CAX, [3 1 2]));
epid_CAX = reshape(epid_CAX,[dLen, lLen]);


% Builds the f matrix, which is the signal for a certain field size at a
% depth of zero divided by the signal at that same field size but with
% varying depth.

mat_f = bsxfun(@rdivide, epid_CAX((length(d_s)-1)/2+1,:),epid_CAX);


end

