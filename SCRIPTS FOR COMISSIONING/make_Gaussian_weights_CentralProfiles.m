% This script makes the weights for the multi-Gaussian 2D dose correction.

% It takes the EPIDs prepared by backscatter correction and loads them,
% then processes them.

% It also takes the TPS dose exported maps.

clc; close all; clear all; 
addpath(genpath(pwd));

dosave=true;

load('Comissioning data\EPID images with centered phantoms (F)\EPIDs_prepared.mat')

cd 'Comissioning data\TPS phantom mid-depth dose (F)'
names = dir('w*');
names = {names.name};
ECLIPSEs = cellfun(@(name) dicomread(char(name)), names, 'UniformOutput', 0);
eclipse_info = dicominfo(char(names{1}));
ECLIPSEs = cellfun(@(eclip) 100*double(eclip)*eclipse_info.DoseGridScaling, ECLIPSEs, 'UniformOutput', 0);
save('ECLIPSEs.mat', 'ECLIPSEs') 

cd ../..
cd 'Gaussian weights'
working_dir=pwd;

% 6. GOING FROM S TO D WITH THE SUM OF 4 GAUSSIANS
sprintf('START GAUSSIAN WEIGHTING')
SD1=1.7; % makes a Gaussian with SD=1.7pixels/0.523pixels/mm=3.2mm (Van Herk penumbras)
SD2=SD1*2; % makes a Gaussian 2x wider (VH penumbra at larger depths)
SD3=SD1*10; % makes a Gaussian 10x wider (scatter)
SD4=SD1*30; % makes a Gaussian 30x wider (scatter at larger depths)

x=1:1000;    m=(max(x)-min(x))/2+0.5;  

s1=SD1/.523; g1=gauss_distribution(x,m,s1);   
s2=SD2/.523; g2=gauss_distribution(x,m,s2);   
s3=SD3/.523; g3=gauss_distribution(x,m,s3);  
s4=SD4/.523; g4=gauss_distribution(x,m,s4); 

% -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/

for i=6%1:length(EPIDs)
    i
    epid=EPIDs{i};
    eclipse=ECLIPSEs{i};
       
    name = names{i};
w_string = name(1:3);
l_string = name(4:6);

% correct the EPID for backscatter
cd ..
cd 'Backscatter correction'
eval(['load(''bsc_',w_string,l_string,'.mat'');']);
epid=epid./backscatter_corr; %NOTE: THE GAUSSIAN WEIGHTS AND EDGE CORRECTION CURVES ARE CALCULATED FROM THE BACKSCATTER-CORRETED EPID!
cd ..
cd 'Gaussian weights'
    

% 7.        MAKE A BINARY MASK OF FIELD USING EPID IMAGE
mask=zeros(384,512);
epid_elements=sort(epid(:),'descend');
epid_64_max=mean(epid_elements(1:64));
epid_64_min=mean(epid_elements(end-64:end));
mask=+(epid>abs(epid_64_max+epid_64_min)/4);

% figure; imagesc(mask); colormap('bone')
% title 'mask, from EPID image'
% axis equal; axis tight; 
% colorbar; set(gca, 'CLim', [0 1]);

% 8.        MAKE A BINARY MASK OF FIELD USING TPS IMAGE
mask_eclipse=zeros(384,512);
eclipse_64_max=sort(eclipse(:),'descend');
eclipse_64_max=mean(eclipse_64_max(1:64));
mask_eclipse=+(eclipse>abs(eclipse_64_max)*.5);

% figure; imagesc(mask_eclipse); colormap('bone')
% title 'mask, from Eclipse image'
% axis equal; axis tight; 
% colorbar; set(gca, 'CLim', [0 1]);


% 9.        PLOT INTERSECTION OF THE TWO MASKS ABOVE (THIS WILL AFFECT YOUR FINAL PERCENT
% DIFF MAP. IN OTHER WORDS, IT affects YOUR TPS MAP / EPID MAP DISCORDANCE DUE TO EPID SAG.)
 mask_difference=mask-mask_eclipse;
% figure; imagesc(mask_difference); title 'masks intersection before shift(+1=EPID only, -1=TPS only)'; axis equal; axis tight; colorbar; set(gca, 'CLim', [-1 1]);

% 
% % 10. correct for S-I and L-R offset due to EPID sag

    epidsagSImagn=abs(sum(mask_difference(1:192,256))-sum(mask_difference(193:384,256)))/2;
    epidsagSIsign=sign((sum(mask_difference(1:192,256))-sum(mask_difference(193:384,256))));
    
    epidsagLRmagn=abs(sum(mask_difference(192,1:256))-sum(mask_difference(192,257:512)))/2;
    epidsagLRsign=sign((sum(mask_difference(192,1:256))-sum(mask_difference(192,257:512))));
    
    EPID_sag_cm=[epidsagSImagn*.05 epidsagLRmagn*.05]
    sprintf('This was the approx EPID sag (S-I,L-R)')
    
    epid=circshift(epid,[round(epidsagSIsign*epidsagSImagn) round(epidsagLRsign*epidsagLRmagn)]);

    mask=zeros(384,512);
    mask=+(epid>abs(epid_64_max+epid_64_min)/4);
    mask_difference=mask-mask_eclipse;
    if nnz(mask_difference)>.05*384*512
    figure; imagesc(mask_difference); title 'masks intersection after shift(+1=EPID only, -1=TPS only)'
    axis equal; axis tight; colorbar; set(gca, 'CLim', [-1 1]); set(gcf,'position',[0 0 500 500])
    end




sprintf('CROSS-PLANE')

row=192;

%[w_cross,ConvRescaleFactor_cross]=Fit2GaussConv(epid(row,:)/trapz(epid(row,:)),eclipse(row,:),SD1,SD2,SD3,SD4);
[w_cross,ConvRescaleFactor_cross]=Fit2GaussConv(epid(row,:),eclipse(row,:),SD1,SD2,SD3,SD4);

w1=w_cross(1); %weight of Gaussian 1
w2=w_cross(2); %weight of Gaussian 2
w3=w_cross(3); %weight of Gaussian 3
w4=w_cross(4); %weight of Gaussian 4

w_cr_avg=[w1 w2 w3 w4];

gsum=w1*g1+w2*g2+w3*g3+w4*g4;   %gsum=gsum/trapz(gsum);
%figure; plot(x,g1,x,g2,x,g3,x,g4,x,gsum); legend('Gaussian 1','Gaussian 2','Gaussian 3','Gaussian 4','Sum'); xlim([400 600]); %ylim([0 0.1])
tps_profile=eclipse(row,:);
epid_profile=epid(row,:); %epid_profile=epid_profile/trapz(epid_profile);
test=conv(epid_profile,gsum,'same')*ConvRescaleFactor_cross;
figure; plot(1:length(epid_profile),epid_profile/max(epid_profile)*max(tps_profile),1:length(epid_profile),tps_profile,1:length(epid_profile),test); 
legend('epid (arbitrary scale)','TPS dose','conv(epid,gsum)','location','south'); 
title([w_string ' ' l_string ' crossplane']); set(gcf,'position',[0 500 600 500])
% to zoom in accurately
slope=diff(tps_profile); [a,b]=max(slope); [c,d]=min(slope);
xlim([b-30 d+30]); ylim([0.8*max(tps_profile) 1.1*max(tps_profile)])

% -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/

sprintf('IN-PLANE')

col=256;

%[w_in,ConvRescaleFactor_in]=Fit2GaussConv(epid(:,col)'/trapz(epid(:,col)),eclipse(:,col)',SD1,SD2,SD3,SD4);
[w_in,ConvRescaleFactor_in]=Fit2GaussConv(epid(:,col)',eclipse(:,col)',SD1,SD2,SD3,SD4);

w1=w_in(1); %weight of Gaussian 1
w2=w_in(2); %weight of Gaussian 2
w3=w_in(3); %weight of Gaussian 3
w4=w_in(4); %weight of Gaussian 3

w_in_avg=[w1 w2 w3 w4];

gsum=(w1*g1+w2*g2+w3*g3+w4*g4);   %gsum=gsum/trapz(gsum);
%figure; plot(x,g1,x,g2,x,g3,x,g4,x,gsum); legend('Gaussian 1','Gaussian 2','Gaussian 3','Gaussian 4','Sum'); xlim([400 600]); %ylim([0 0.1])
tps_profile=eclipse(:,col);
epid_profile=epid(:,col);
%epid_profile=epid_profile/trapz(epid_profile);
test=conv(epid_profile,gsum,'same')*ConvRescaleFactor_in;
figure; plot(1:length(epid_profile),epid_profile/max(epid_profile)*max(tps_profile),1:length(epid_profile),tps_profile,1:length(epid_profile),test); 
legend('epid (arbitrary scale)','TPS dose','conv(epid,gsum)','location','south'); 
title([w_string ' ' l_string ' inplane']); set(gcf,'position',[600 500 600 500])
% to zoom in accurately
slope=diff(tps_profile); [a,b]=max(slope); [c,d]=min(slope);
xlim([b-30 d+30]); ylim([0.8*max(tps_profile) 1.1*max(tps_profile)])
% 
% % -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/
%  
if dosave
eval(['save gw_',w_string,l_string,' w_cr_avg w_in_avg ConvRescaleFactor_cross ConvRescaleFactor_in;']);
end

end
sprintf('END GAUSSIAN WEIGHTING')
cd ..
