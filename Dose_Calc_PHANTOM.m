% you need
% epid
% eclipse
% w of the phantomS


% Build WED (water equivalent depth) maps of phantoms

WED_source2epid=w*ones(384,512);
WED_source2isoplane=w/2*ones(384,512);
WED_CAX=w;
Fwindex = round((WED_source2epid-ones(384,512)*(ws(1)))/0.1)+1
Flindex = round((l-ls(1))/0.1)+1
F_map = FmatInt(Fwindex,Flindex);
F_map = reshape(F_map,384,512);
%you need to get the correct row and col, for w and l
f_map=ones(384,512);
TPRratio_map=ones(384,512);



%-------------------------------------------------------------------------

% MAKE A BINARY MASK OF FIELD USING EPID IMAGE

epid_64_max = mean2(epid(189:196,253:260));
epid_64_min = mean2(epid(1:8,1:8));
mask=+(epid>abs(epid_64_max+epid_64_min)/4);

% figure; imagesc(mask); colormap('bone')
% title 'mask, from EPID image'
% axis equal; axis tight; 
% colorbar; set(gca, 'CLim', [0 1]);

% 8.        MAKE A BINARY MASK OF FIELD USING TPS IMAGE
% mask_eclipse=zeros(384,512);

eclipse_64_max = mean2(eclipse(189:196,253:260));
mask_eclipse=+(eclipse>abs(eclipse_64_max)*.5);

% figure; imagesc(mask_eclipse); colormap('bone')
% title 'mask, from Eclipse image'
% axis equal; axis tight; 
% colorbar; set(gca, 'CLim', [0 1]);


%% 9.        PLOT INTERSECTION OF THE TWO MASKS ABOVE (THIS WILL AFFECT YOUR FINAL PERCENT
% DIFF MAP. IN OTHER WORDS, IT affects YOUR TPS MAP / EPID MAP DISCORDANCE DUE TO EPID SAG.)
mask_difference=mask-mask_eclipse;
% figure; imagesc(mask_difference); title 'masks intersection before shift(+1=EPID only, -1=TPS only)'; axis equal; axis tight; colorbar; set(gca, 'CLim', [-1 1]);

l_eclipse=round(sqrt(nnz(mask_eclipse)*0.05227*0.05227));
l_epid=round(sqrt(nnz(mask)*0.05227*0.05227));

if l_eclipse ~= l_epid
    l_eclipse
    l_epid
    sprintf('field sizes of the TPS and EPID image do not agree! Script terminated')
else
    l=l_epid;
end


%% 12         CALCULATE DOSE USING CAX DATA ONLY
DOSE_NOCORR=mask.*epid.*TMRratio_map.*f_map./F_map;

%DOSE_NOCORR(isnan(DOSE_NOCORR))=0;

figure; imagesc(eclipse); axis equal; axis tight; colorbar; title('TPS Dose'); 
figure; imagesc(DOSE_NOCORR); axis equal; axis tight;colorbar; title('EPID Dose, uncorrected'); 


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
%% OFF-AXIS CORRECTION by CONVOLUTION

%   MAKE 4 pre-determined of GAUSSIANS
x=1:1000;    m=(max(x)-min(x))/2+0.5;

SD1=1.7; % makes a Gaussian with SD=3.2mm (Van Herk penumbras)
SD2=SD1*2; % makes a Gaussian 25x wider (penumbra at larger depths)
SD3=SD1*10; % makes a Gaussian 10x wider (scatter)
SD4=SD1*30; % makes a Gaussian 20x wider (scatter at larger depths)

s1=SD1/.523; g1=gauss_distribution(x,m,s1);   
s2=SD2/.523; g2=gauss_distribution(x,m,s2);   
s3=SD3/.523; g3=gauss_distribution(x,m,s3);  
s4=SD4/.523; g4=gauss_distribution(x,m,s4);
clear s1 s2 s3 s4 x m SD1 SD2 SD3 SD4

%% LOAD WEIGHTINGS OF the 4 GAUSSIANS 
cd 'Gaussian weights'
eval(['load(''gw_',w_string,l_string,'.mat'');']);
cd .

%%   CONVOLUTION 1 - CROSS-PLANE DIRECTION
gsum_cr=w_cr_avg(1)*g1+w_cr_avg(2)*g2+w_cr_avg(3)*g3+w_cr_avg(4)*g4;

conv_1=zeros(384,512);
for row=1:384;
    
%   GIVE THEM RELATIVE WEIGHTS
    %%figure; plot(x,g1,x,g2,x,g3,x,g4,x,gsum); legend('Gaussian 1','Gaussian 2','Gaussian 3','Gaussian 4','Sum'); xlim([100 412]); %ylim([0 0.1])
    
    profile=epid(row,:);%/trapz(epid(row,:));
    profile (isnan(profile))=0;
    conv_1(row,:)=conv(profile,gsum_cr,'same');
    
    % Now that I gave correct shape, I can renormalize to approximately the correct height.
    
    %conv_1(row,:)=conv_1(row,:)*trapz(epid(row,:));
    
    % Another way to Do this: by finding the midway point along this cross plane profile and
    % renormalize there. But if no points along this row are in the field, then
    % set the whole row to zeros
        
%     first=min(find(mask(row,:)));
%     last=max(find(mask(row,:)));
%     mid=first+round((last-first)/2);
%     if mid>1
%         temp_post_conv=conv_1(row,:);
%         temp_pre_conv=epid(row,:);
%         conv_1(row,:)=conv_1(row,:)/mean(temp_post_conv(mid-4:mid+4))*mean(temp_pre_conv(mid-4:mid+4));  
%     else
%         conv_1(row,:)=zeros(1,512);
%     end     
end
%figure; imagesc(epid), axis equal; axis tight
%figure; imagesc(conv_1), axis equal; axis tight
%conv_1=conv_1/mean(mean(conv_1(189:196,253:260)));
clear row temp_corr temp_epid epid_profile
clear first last mid

%%   CONVOLUTION 2 - IN-PLANE DIRECTION

gsum_in=w_in_avg(1)*g1+w_in_avg(2)*g2+w_in_avg(3)*g3+w_in_avg(4)*g4;
conv_2=zeros(384,512);
for col=1:512;
%   GIVE THEM RELATIVE WEIGHTS
    %%figure; plot(x,g1,x,g2,x,g3,x,g4,x,gsum); legend('Gaussian 1','Gaussian 2','Gaussian 3','Gaussian 4','Sum'); xlim([100 412]); %ylim([0 0.1])

    profile=conv_1(:,col);%/trapz(conv_1(:,col));
    profile (isnan(profile))=0;
    conv_2(:,col)=conv(profile,gsum_in,'same');

    % Now that I gave correct shape, I must renormalize to the correct height.
%    conv_2(:,col)=conv_2(:,col)*trapz(conv_1(:,col));

    % Do this by finding the midway point along this cross plane profile and
    % renormalize there.
    
%     first=min(find(mask(:,col)));
%     last=max(find(mask(:,col)));
%     mid=first+round((last-first)/4);
%     
%     if mid>1
%         temp_post_conv=conv_2(:,col);
%         temp_pre_conv=conv_1(:,col);
%         conv_2(:,col)=conv_2(:,col)/mean(temp_post_conv(mid-4:mid+4))*mean(temp_pre_conv(mid-4:mid+4));  
%     else
%         conv_2(:,col)=transpose(zeros(1,384));
%     end
    
end
%figure; imagesc(conv_2), axis equal; axis tight
clear col temp_corr temp_epid epid_profile
clear g1 g2 g3 g4 gsum
%clear w_cr_avg w_in_tot
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


DOSE_CONV=conv_2.*mask.*TMRratio_map.*f_map./F_map;
%DOSE_CONV(isnan(DOSE_CONV))=0;
%this is actually OFF by a factor, with the correct shape. it's a temporary quantity

% Now, I KNOW I can trust the CAX value of DOSE_NOCORR, so let's shift DOSE_CONV
% so that it has the same CAX value as DOSE_NOCORR.

DOSE_CONV=DOSE_CONV*mean(mean(DOSE_NOCORR(189:196,253:260)))/mean(mean(DOSE_CONV(189:196,253:260)));

if ThisIsComissioning
    make_Gaussian_HornsCorrection
end

% LOAD empirical 2D shape correction (Horn Correction Matrix)
eval(['load(''C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\RITE Dos 2015\',UnitStr,'\Gaussian_CAX_corr\',EnergyStr,'\ghc_l',l_big_string,'w',w_string,'.mat'');']);

DOSE_CONV=DOSE_CONV./horns_corr*scalar;
figure; imagesc(DOSE_CONV); colorbar
     axis equal; axis tight; title('Measured dose (EPID)'); colorbar; set(gca, 'CLim', [0.0*max(max(eclipse)) 1.1*max(max(eclipse))]); 
     set(gca,'Xtick',[],'Ytick',[])


     
     

PercentDiffMatrix=100*mask.*(DOSE_CONV-eclipse)/max(max(eclipse));
figure; imagesc(PercentDiffMatrix); title 'Percent difference, Convolution correction';axis equal; axis tight; colorbar; 
set(gca, 'CLim', [-15 15]); set(gcf,'position',[10 500 550 450])
     set(gca,'Xtick',[],'Ytick',[])
PercentDiffCAX_Conv3=mean(mean(PercentDiffMatrix(189:196,253:260)));


    % CROSS-PLANE PROFILE
    [a,x1]=max(diff(eclipse(192,:)));
    [a,x2]=min(diff(eclipse(192,:)));
    y1=max(eclipse(192,:));
    all_figs(7)=figure; 
    plot(1:512,eclipse(192,:),1:512,DOSE_NOCORR(192,:),'g',1:512,DOSE_CONV(192,:),'c',1:512,DOSE_CONV(192,:),'r--');
    legend('TPS dose','D_E_P_I_D^C^A^X  (CAX only)','D_E_P_I_D^C^A^X\otimesG(sum) raw','D_E_P_I_D^C^A^X\otimesG(sum) corr','location','south'); 
    try xlim([round(x1-20) round(x2+20)]); ylim([round(0.5*y1) round(1.5*y1)]); end
    xlabel('Crossplane pixel')
    ylabel('Dose (cGy)')
    set(gcf,'position',[0 100 500 500])
    axis square

    % IN-PLANE PROFILE
    [a,x3]=max(diff(eclipse(:,256)));
    [a,x4]=min(diff(eclipse(:,256)));
    y3=max(eclipse(:,256));
    all_figs(8)=figure; 
    plot(1:384,eclipse(:,256),1:384,DOSE_NOCORR(:,256),'g',1:384,DOSE_CONV(:,256),'c',1:384,DOSE_CONV(:,256),'r--');
    legend('TPS dose','D_E_P_I_D^C^A^X  (CAX only)','D_E_P_I_D^C^A^X\otimesG(sum) raw','D_E_P_I_D^C^A^X\otimesG(sum) corr','location','south'); 
    try xlim([round(x3-20) round(x4+20)]); ylim([round(0.5*y3) round(1.5*y3)]); end
    xlabel('Inplane pixel')
    ylabel('Dose (cGy)')
    set(gcf,'position',[500 100 500 500])
    axis square


