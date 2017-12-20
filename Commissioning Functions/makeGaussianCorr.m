function [ws_in, ws_cr, DoseConvs, mat_HornCorr] = makeGaussianCorr(tpsValues, epidData_F, matInt_F, epidDims, l_s, w_s, settings)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here



SD1 = 1.7;
SD2 = SD1*2;
SD3 = SD1*10;
SD4 = SD1*30;

stDevs = [SD1, SD1, SD3, SD4];

x=1:1000;
m=(max(x)-min(x))/2+0.5;

gaussians = gaussDistribution(x, m, stDevs/0.523);

%Should horns be BSCed? If so, do this outside and pass EPIDs in after
%having been corrected.
mat_HornCorr = zeros(size(epidData_F));
DoseConvs = zeros(size(epidData_F));

ws_cr = zeros(4,size(epidData_F,3));
ws_in = zeros(4,size(epidData_F,3));

[crossPlaneWindow, inPlaneWindow] = getCentralAveragingWindow(epidDims, settings.centralAveragingWindowSideLength);

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
    
    F_map = matInt_F(Fwindex,Flindex);
    F_map = reshape(F_map, epidDims(2), epidDims(1));
    fmap = ones(epidDims(2), epidDims(1));
    TMRratio = ones(epidDims(2), epidDims(1));
    
    % Adjusts the EPIDs for left-right and superior-inferior displacement.
    epid_max = mean2(epidData_F(inPlaneWindow, crossPlaneWindow ,i));
    epid_min = mean2(epidData_F(1:8,1:8,i));
    mask = (epidData_F(:,:,i) > abs(epid_max+epid_min)/2);
    
    tps_max = mean2(tpsValues(inPlaneWindow, crossPlaneWindow, i));
    tps_mask = (tpsValues(:,:,i)>abs(tps_max)/2);
    
    mask_diff = mask-tps_mask;
        

    shiftEPIDsF = epidData_F(:,:,i);
    epid_elements=sort(shiftEPIDsF(:),'descend');
    epid_64_max=mean(epid_elements(101:151));
    epid_64_min=mean(epid_elements(end-150:end-100));
    mask_epid=+(shiftEPIDsF>abs(epid_64_max+epid_64_min)/2);
    
    % In-plane gaussian
    [weightsInPlane, ConvRescaleFactor_in]=Fit2GaussConv(shiftEPIDsF(:,256)',tpsValues(:,256,i)',SD1,SD2,SD3,SD4);

    ws_in(:,i) = weightsInPlane;
    
    gsumin = (sum(weightsInPlane.*gaussians)/trapz(sum(weightsInPlane.*gaussians))); 
        
    % Cross-plane gaussian
    
    [weightsCrossPlane, ConvRescaleFactor_cross]=Fit2GaussConv(shiftEPIDsF(192,:),tpsValues(192,:,i),SD1,SD2,SD3,SD4);

    ws_cr(:,i) = weightsCrossPlane;
    
    gsumcr = (sum(weightsCrossPlane.*gaussians)/trapz(sum(weightsCrossPlane.*gaussians))):

    
    
    DoseConv = getDoseConv(shiftEPIDsF,mask_epid,gsumcr,gsumin,TMRratio,F_map,fmap);
    DoseConvs(:,:,i) = DoseConv;

    
    mat_HornCorr(:,:,i) = makeGHC(DoseConv, tpsValues(:,:,i), l);

    
end

