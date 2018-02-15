function [ws_in, ws_cr, DoseConvs, mat_HornCorr] = makeGaussianCorr(tpsValues, epidData_F, matInt_F, epidDims, epidDimsAtIso, l_s, w_s, settings)
%[ws_in, ws_cr, DoseConvs, mat_HornCorr] = makeGaussianCorr(tpsValues, epidData_F, matInt_F, epidDims, epidDimsAtIso, l_s, w_s, settings)

stDevs = settings.startingStDev * settings.getGaussianCorrectionStDevs();
numGaussians = length(stDevs);

x = 1:1000;
m = (max(x)-min(x))/2+0.5;

gaussians = gaussDistribution(x, m, stDevs ./ epidDimsAtIso(1));

%Should horns be BSCed? If so, do this outside and pass EPIDs in after
%having been corrected.
mat_HornCorr = zeros(size(epidData_F));
DoseConvs = zeros(size(epidData_F));

ws_cr = zeros(numGaussians, size(epidData_F,3));
ws_in = zeros(numGaussians, size(epidData_F,3));

% [crossPlaneWindow, inPlaneWindow] = getCentralAveragingWindow(epidDims, settings.centralAveragingWindowSideLength);

for i=1:size(epidData_F,3)
    % What I'll do is use the w_s and l_s to index properly rather than
    % have many different ones. I guess. Something like have a map from its
    % position in the w_s and l_s arrays to the third dimension of the BSC
    % matrix. May or may not be more efficient and useful.

    l = l_s(mod(i-1,length(l_s))+1);
    w = w_s(floor((i-1)/length(l_s))+1);
    
    WED_source2epid = w*ones(epidDims(2), epidDims(1));
    Fwindex = round((WED_source2epid-ones(epidDims(2), epidDims(1))*(w_s(1)))/0.1)+1;
    Flindex = round((l-l_s(1))/0.1)+1;
    
    map_F = matInt_F(Fwindex,Flindex);
    map_F = reshape(map_F, epidDims(2), epidDims(1));
    map_f = ones(epidDims(2), epidDims(1));
    TMRratio = ones(epidDims(2), epidDims(1));
    
%     % Adjusts the EPIDs for left-right and superior-inferior displacement.
%     epid_max = mean2(epidData_F(inPlaneWindow, crossPlaneWindow ,i));
%     epid_min = mean2(epidData_F(1:8,1:8,i));
%     mask = (epidData_F(:,:,i) > abs(epid_max+epid_min)/2);
%     
%     tps_max = mean2(tpsValues(inPlaneWindow, crossPlaneWindow, i));
%     tps_mask = (tpsValues(:,:,i)>abs(tps_max)/2);
       

    shiftEPIDsF = epidData_F(:,:,i);
    
    maskEpid = createMinMaxMask(shiftEPIDsF, settings);
           
    
    % In-plane gaussian
    crossPlaneCentre = ceil(epidDims(1) / 2);
    
    weightsInPlane = Fit2GaussConv(shiftEPIDsF(:,crossPlaneCentre)',tpsValues(:,crossPlaneCentre,i)', stDevs, epidDimsAtIso, settings);

    ws_in(:,i) = weightsInPlane;
    
    gSumInPlane = (sum(weightsInPlane.*gaussians)/trapz(sum(weightsInPlane.*gaussians))); 
        
    % Cross-plane gaussian
    inPlaneCentre = ceil(epidDims(2) / 2);
    
    weightsCrossPlane = Fit2GaussConv(shiftEPIDsF(inPlaneCentre,:),tpsValues(inPlaneCentre,:,i), stDevs, epidDimsAtIso, settings);

    ws_cr(:,i) = weightsCrossPlane;
    
    gSumCrossPlane = (sum(weightsCrossPlane.*gaussians)/trapz(sum(weightsCrossPlane.*gaussians)));

    
    
    DoseConv = getDoseConv(shiftEPIDsF, maskEpid, gSumCrossPlane, gSumInPlane, TMRratio, map_F, map_f);
    DoseConvs(:,:,i) = DoseConv;

    
    mat_HornCorr(:,:,i) = makeGHC(DoseConv, tpsValues(:,:,i), l);

    
end

