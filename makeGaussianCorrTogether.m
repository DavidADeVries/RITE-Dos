function [ ws_in, ws_cr, DoseConvs, HCM ] = makeGaussianCorrTogether( ECLIPSEs, EPIDsF, TMRratio, FmatInt,fmatInt )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
SD1 = 1.7;
SD2 = SD1*2;
SD3 = SD1*10;
SD4 = SD1*30;



x=1:1000;
m=(max(x)-min(x))/2+0.5;

g1 = gauss_distribution(x,m,SD1/.523);
g2 = gauss_distribution(x,m,SD2/.523);
g3 = gauss_distribution(x,m,SD3/.523);
g4 = gauss_distribution(x,m,SD4/.523);

%Should horns be BSCed? If so, do this outside and pass EPIDs in after
%having been corrected.
% HCM = zeros(size(EPIDsF));
DoseConvs = zeros(size(EPIDsF));
% ConvRescaleFactors_cross = zeros(1,size(EPIDsF,3));
% ConvRescaleFactors_in = zeros(1,size(EPIDsF,3));
ws_cr = zeros(4,size(EPIDsF,3));
ws_in = zeros(4,size(EPIDsF,3));

for i=1:size(EPIDsF,3)
    % What I'll do is use the w_s and l_s to index properly rather than
    % have many different ones. I guess. Something like have a map from its
    % position in the w_s and l_s arrays to the third dimension of the BSC
    % matrix. May or may not be more efficient and useful.
    l_s=5:5:20;
    w_s=5:5:40;
    l=l_s(mod(i-1,length(l_s))+1);
    w=w_s(floor((i-1)/length(l_s))+1);
    
    WED_source2epid=w*ones(384,512);
    Fwindex = round((WED_source2epid-ones(384,512)*(w_s(1)))/0.1)+1;
    Flindex = round((l-l_s(1))/0.1)+1;
    
    F_map = FmatInt(Fwindex,Flindex);
    F_map = reshape(F_map,384,512);
    fmap = ones(384,512);
    TMRratio = ones(384,512);
    
    %% Adjusts the EPIDs for left-right and superior-inferior displacement.
    epid_max = mean2(EPIDsF(189:196,253:260,i));
    epid_min = mean2(EPIDsF(1:8,1:8,i));
    mask = (EPIDsF(:,:,i) > abs(epid_max+epid_min)/4);
    
    eclipse_max = mean2(ECLIPSEs(189:196,253:260,i));
    mask_eclipse = (ECLIPSEs(:,:,i)>abs(eclipse_max)/2);
    
    mask_diff = mask-mask_eclipse;
    
%     epidsagSImagn=abs(sum(mask_diff(1:192,256))-sum(mask_diff(193:384,256)))/2;
%     epidsagSIsign=sign((sum(mask_diff(1:192,256))-sum(mask_diff(193:384,256))));
%     
%     epidsagLRmagn=abs(sum(mask_diff(192,1:256))-sum(mask_diff(192,257:512)))/2;
%     epidsagLRsign=sign((sum(mask_diff(192,1:256))-sum(mask_diff(192,257:512))));
    
    %Just for test purposes
    % EPID_sag_cm=[epidsagSImagn*.05 epidsagLRmagn*.05];
    
    
%     shiftEPIDsF = circshift(EPIDsF(:,:,i), [round(epidsagSIsign*epidsagSImagn) round(epidsagLRsign*epidsagLRmagn)]);   
    shiftEPIDsF = EPIDsF(:,:,i);
    epid_elements=sort(shiftEPIDsF(:),'descend');
    epid_64_max=mean(epid_elements(101:151));
    epid_64_min=mean(epid_elements(end-150:end-100));
    mask_epid=+(shiftEPIDsF>abs(epid_64_max+epid_64_min)/4);
    %% Cross-plane gaussian
    
    [w_cross,ConvRescaleFactor_cross]=Fit2GaussConv(shiftEPIDsF(192,:),ECLIPSEs(192,:,i),SD1,SD2,SD3,SD4);

    w1=w_cross(1); %weight of Gaussian 1
    w2=w_cross(2); %weight of Gaussian 2
    w3=w_cross(3); %weight of Gaussian 3
    w4=w_cross(4); %weight of Gaussian 4

    w_cr=[w1 w2 w3 w4];
    ws_cr(:,i) = w_cr;
    
    gsumcr=(w1*g1+w2*g2+w3*g3+w4*g4)/trapz(w1*g1+w2*g2+w3*g3+w4*g4);

    
    %figure; plot(x,g1,x,g2,x,g3,x,g4,x,gsum); legend('Gaussian 1','Gaussian 2','Gaussian 3','Gaussian 4','Sum'); xlim([400 600]); %ylim([0 0.1])
%     tps_profile=ECLIPSEs(192,:,i);
%     epid_profile=shiftEPIDsF(192,:);
%     test=conv(epid_profile,gsumcr,'same')*ConvRescaleFactor_cross;
%     figure; plot(1:length(epid_profile),epid_profile/max(epid_profile)*max(tps_profile),1:length(epid_profile),tps_profile,1:length(epid_profile),test); 
%     legend('epid (arbitrary scale)','TPS dose','conv(epid,gsum)','location','northeastoutside'); 
    %title([w_string ' ' l_string ' crossplane']); set(gcf,'position',[0 500 600 500])
    % to zoom in accurately
%     slope=diff(tps_profile); [~,b]=max(slope); [~,d]=min(slope);
%     xlim([b-30 d+30]); ylim([0.8*max(tps_profile) 1.1*max(tps_profile)])
    conv_1=zeros(384,512);
    for row=1:384;
    
%   GIVE THEM RELATIVE WEIGHTS
%     normfactor=trapz(EPIDsF(row,:,i));
    
    profile=EPIDsF(row,:,i);%/normfactor;
    conv_1(row,:)=conv(profile,gsumcr,'same');
    
    % Now that I gave correct shape, I must renormalize to the correct height.
    % Do this by finding the midway point along this cross plane profile and
    % renormalize there. But if no points along this row are in the field, then
    % set the whole row to zeros
    
    first=find(mask(row,:), 1 );
    last=find(mask(row,:), 1, 'last' );
    mid=first+round((last-first)/2);
    
    if mid>1
        temp_post_conv=conv_1(row,:);
        temp_pre_conv=EPIDsF(row,:,i);
        conv_1(row,:)=conv_1(row,:)/mean(temp_post_conv(mid-4:mid+4))*mean(temp_pre_conv(mid-4:mid+4));  
    else
        conv_1(row,:)=zeros(1,512);
    end
       
end
    %% In-plane gaussian
    [w_in,ConvRescaleFactor_in]=Fit2GaussConv(conv_1(:,256)',ECLIPSEs(:,256,i)',SD1,SD2,SD3,SD4);
%     [w_in,ConvRescaleFactor_in]=Fit2GaussConv(shiftEPIDsF(:,256)',ECLIPSEs(:,256,i)',SD1,SD2,SD3,SD4);

    w1=w_in(1); %weight of Gaussian 1
    w2=w_in(2); %weight of Gaussian 2
    w3=w_in(3); %weight of Gaussian 3
    w4=w_in(4); %weight of Gaussian 3

    w_in=[w1 w2 w3 w4];
    ws_in(:,i) = w_in;
    
    gsumin=(w1*g1+w2*g2+w3*g3+w4*g4)/trapz(w1*g1+w2*g2+w3*g3+w4*g4); 
    
%     tps_profile=ECLIPSEs(:,256,i);
%     epid_profile=shiftEPIDsF(:,256);
%     test=conv(epid_profile,gsumin,'same')*ConvRescaleFactor_in;
    
%     figure; plot(1:length(epid_profile),epid_profile/max(epid_profile)*max(tps_profile),1:length(epid_profile),tps_profile,1:length(epid_profile),test); 
%     legend('epid (arbitrary scale)','TPS dose','conv(epid,gsum)','location','south'); 
%     title([w_string ' ' l_string ' inplane']); set(gcf,'position',[600 500 600 500])
%     % to zoom in accurately
%     slope=diff(tps_profile); [a,b]=max(slope); [c,d]=min(slope);
%     xlim([b-30 d+30]); ylim([0.8*max(tps_profile) 1.1*max(tps_profile)])
    

    
%%
    DoseConv = getDoseConv(shiftEPIDsF,mask_epid,gsumcr,gsumin,TMRratio,F_map,fmap);
    DOSE_NOCORR = shiftEPIDsF./F_map;
%     DoseConv = DoseConv * (mean2(DOSE_NOCORR(189:196,253:260))./mean2(DoseConv(189:196,253:260)));
    DoseConvs(:,:,i) = DoseConv;
%     doseconv_profile = DoseConv(192,:);
%     figure; plot(1:length(doseconv_profile),doseconv_profile,1:length(doseconv_profile),tps_profile,1:length(doseconv_profile),EPIDsF(192,:,i)./F_map(192,:));
%     doseconv_profile = DoseConv(:,256);
%     tps_profile=ECLIPSEs(:,256,i);
%     figure; plot(1:length(doseconv_profile),doseconv_profile,1:length(doseconv_profile),tps_profile,1:length(doseconv_profile),EPIDsF(:,256,i)./F_map(:,256));
%    
    
%     imagesc(DoseConv)
%     figure()
%     imagesc((DoseConv-ECLIPSEs(:,:,i))./ECLIPSEs(:,:,i)*100)
%     colorbar; set(gca, 'CLim', [-5 5]);
%     title('DoseConv vs Eclipse')
%     figure()
%     imagesc((EPIDsF(:,:,i)./F_map-ECLIPSEs(:,:,i))./ECLIPSEs(:,:,i)*100)
    
    HCM(:,:,i) = makeGHC(DoseConv, ECLIPSEs(:,:,i), l);
%     
%     tps_profile=ECLIPSEs(192,:,i);
%     doseconv_profile = DoseConv(192,:).*HCM(192,:,i);
%     figure; plot(1:length(doseconv_profile),doseconv_profile,1:length(doseconv_profile),tps_profile,1:length(doseconv_profile),EPIDsF(192,:,i)./F_map(192,:));
%     title('With HCM')
%     doseconv_profile = DoseConv(:,256).*HCM(:,256,i);
%     tps_profile=ECLIPSEs(:,256,i);
%     figure; plot(1:length(doseconv_profile),doseconv_profile,1:length(doseconv_profile),tps_profile,1:length(doseconv_profile),EPIDsF(:,256,i)./F_map(:,256));
%     title('With HCM')
end
end
