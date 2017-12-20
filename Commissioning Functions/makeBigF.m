function mat_F = makeBigF(tpsValues, epidData_F, w_s, l_s, epidDims, settings)
%mat_F = makeBigF(tpsValues, epidData_F, w_s, l_s, epidDims, settings)

wLen = length(w_s);
lLen = length(l_s);

numTpsValues = wLen*lLen;

% Gets the dose maps from the treatment planning system data and takes the
% center mean.
% All of the files will have the same dose grid scaling and so just read
% the first ones.
doseTps = zeros(1, numTpsValues);

[crossPlaneWindow, inPlaneWindow] = getCentralAveragingWindow(epidDims, settings.centralAveragingWindowSideLength);

for i=1:numTpsValues
    TPSmap = tpsValues(:,:,i);
    doseTps(i) = mean2(TPSmap(inPlaneWindow, crossPlaneWindow));
end

doseTps = reshape(doseTps, lLen, wLen)';

% Find the center mean of the signal.
Svalues = mean(mean(epidData_F(inPlaneWindow, crossPlaneWindow, :)));
Svalues = reshape(Svalues, lLen, wLen)';

% F is then signal over dose.
mat_F = Svalues ./ doseTps;

end
