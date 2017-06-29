

%-------------------------------------------------------------------------
% From the CAX WED we estimate "w_string" used for all the off-axis corrections
if (wed_CAX_corr(3)<7.5);                                   w_string='w05' 
elseif (wed_CAX_corr(3)>=7.5) & (wed_CAX_corr(3)<12.5);     w_string='w10' 
elseif (wed_CAX_corr(3)>=12.5) & (wed_CAX_corr(3)<17.5);    w_string='w15'
elseif (wed_CAX_corr(3)>=17.5) & (wed_CAX_corr(3)<22.5);    w_string='w20' 
elseif (wed_CAX_corr(3)>=22.5) & (wed_CAX_corr(3)<27.5);    w_string='w25' 
elseif (wed_CAX_corr(3)>=27.5) & (wed_CAX_corr(3)<32.5);    w_string='w30'
elseif (wed_CAX_corr(3)>=32.5) & (wed_CAX_corr(3)<37.5);    w_string='w35' 
elseif (wed_CAX_corr(3)>=37.5);                             w_string='w40'
elseif (wed_CAX_corr(3)>=37.5);                             w_string='w40'
end

%-------------------------------------------------------------------------

% MAKE A BINARY MASK OF FIELD USING EPID IMAGE
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

% 8.b        MAKE A 80% BINARY MASK OF FIELD USING TPS IMAGE - for later
% analysis to exclude edge effects
mask_eclipse80=zeros(384,512);
mask_eclipse80=+(eclipse>abs(eclipse_64_max)*.8);

% 9.        PLOT INTERSECTION OF THE TWO MASKS ABOVE (THIS WILL AFFECT YOUR FINAL PERCENT
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

    if (l<7.5);                     l_string='l05' 
    elseif (l>=7.5) & (l<12.5);     l_string='l10' 
    elseif (l>=12.5)& (l<17.5);     l_string='l15'
    elseif (l>=17.5);               l_string='l20' 
    end
    if (l<=5);                     l_big_string='l05' 
    elseif (l>5) & (l<=10);     l_big_string='l10' 
    elseif (l>10)& (l<=15);     l_big_string='l15'
    elseif (l>15);               l_big_string='l20' 
    end
    
    w=round(wed_CAX_corr(3))


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% CORRECT FOR FRAMES LOST AT BEAM OFF - these values for our clinic only
if CorrectForBeamOffImageLoss==true
    
if strcmp(UnitStr,'Unit09')
    if strcmp(EnergyStr,'06X')
        if strcmp(ResolutionStr,'Half')
            numImagesCorr=0.1616*MU+0.2133 %data from June 28 2015, 
        elseif strcmp(ResolutionStr,'Full')
            numImagesCorr=0.0941*MU+0.55185 %data from May 12 2015, 
        end
    elseif strcmp(EnergyStr,'15X')
        if strcmp(ResolutionStr,'Half')
            numImagesCorr=0.3725*MU-.68475 %data from May 27 2015, 
        elseif strcmp(ResolutionStr,'Full')
            numImagesCorr=0.1937*MU+0.08325 %data from May 12 2015,
        end
    end
elseif strcmp(UnitStr,'Unit10')
    if strcmp(EnergyStr,'06X')
        numImagesCorr=0.093*MU+0.5581 %data from March 12 2015, S.P.
    elseif strcmp(EnergyStr,'15X')
        numImagesCorr=0.0982*MU+0.3301 %data from Sept 22 2015, S.P.
    end
end

FrameLossCorrFactor=numImagesCorr/nCINEfiles
 if abs(numImagesCorr-nCINEfiles)>=1.3
   warning('THE NUMBER OF IMAGES MAY NOT CORRESPOND THE INPUTTED MU VALUE!');
   return
 end
 
else
    FrameLossCorrFactor=1;
end
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


%LOAD BACKSCATTER CORRECTION, apply it ON EPID IMAGE
%cd ..
cd 'Backscatter correction'
eval(['load(''bsc_',w_string,l_string,'.mat'');']);
epid=epid./backscatter_corr; %NOTE: THE GAUSSIAN WEIGHTS AND EDGE CORRECTION CURVES ARE CALCULATED FROM THE BACKSCATTER-CORRETED EPID!
cd ..


% LOAD WEIGHTINGS OF GAUSSIAN CURVES TO MODEL EDGE BY CONVOLUTION
cd 'Gaussian weights'
eval(['load(''gw_',w_string,l_string,'.mat'');']);
cd ..







 
% 6.        MAKE F, f, TMR MATRICES
% LOAD COMISSIONING DATA

eval(['load(''Comissioning data\F_matrix_interp_with_headings_',UnitStr,'_',EnergyStr,'.mat'');']);
%eval(['load(''comissioning_data\F_matrix_interp_with_headings_',UnitStr,'_',EnergyStr,'.mat'');']);

eval(['load(''Comissioning data\f_matrix_little_with_headings_',UnitStr,'_',EnergyStr,''');']); 

eval(['load(''Comissioning data\TPR_',EnergyStr,''');']);

% You loaded the variable F_matrix_interp_with_headings(402x32) which comes from 
% interpolations of measured values on your unit. 
% Columns are field sizes (l) from 5.0cm to 20.0cm in steps of 0.5cm.
% Rows are equivalent water depth (wed; from source to EPID) 5.0cm to 45.0cm in steps of 0.1cm
Fmatrix=zeros(384,512);

% NEW - %You loaded the variable f_little(82x17) which comes from linear interp 
%of data from March 26 2013 U9 (Stefano).
%cols are equiv sq field sizes 5*5 to 20*20 in steps of 1 cm
%rows are displacement d from midpoint from -20 to 20 in steps of 0.5cm
fmatrix=zeros(384,512);
% OLD - %You loaded the variable f_little(21x11) which comes from linear interp 
%and then interp1 of data from March 26 2013 U9 (Stefano).
%cols are equiv sq field sizes 5*5 to 24*24 in steps of 0.5 cm^2
%rows are displacement d from midpoint from -12 to 12 in steps of 0.5cm
% fmatrix=zeros(384,512);

%You loaded TPR matrix, which is golden data. 
%It has 311 depths, from 0.0 to 31.0 cm in steps of 0.1cm
%and 35 equiv sq field sizes from 6 to 40 in steps of 1
%I want the ratio TMR(w/2 - d)/TMR(w/2) (see formula in paper Peca&Brown 2014)
%where w=wed_total and d is the distance from the halfway wed to the iso.
TPRl=round(l-5);
if TPRl<1
    TPRl=1;
end %this is to approximate fields smaller than l=6 to have l=6
TMRratio=zeros(384,512);

for a=1:384;
        for b=1:512;
            
% 6.1       MAKE F(CAX) MATRIX 
% 1.a. Get the correct column in F_matrix_interp_with_headings
Fslope=(4-2)/(F_matrix_interp_with_headings(1,4)-F_matrix_interp_with_headings(1,2)); 
%  "y" is column number, "x" is field size
Fyint=2-Fslope*F_matrix_interp_with_headings(1,2);
Fcol=round(Fslope*l+Fyint);
clear Fslope Fyint
% 1.b. Get the correct row in F_matrix_interp_with_headings
Fslope=(4-2)/(F_matrix_interp_with_headings(4,1)-F_matrix_interp_with_headings(2,1)); 
%  "y" is row number, "x" is equivalent water depth (wed; from source to EPID)
Fyint=2-Fslope*F_matrix_interp_with_headings(2,1);
Frow=round(Fslope*wed_tot(a,b)+Fyint);
clear Fslope Fyint
% 1.c Approximate for very large and small values of wed and l.
if Fcol>size(F_matrix_interp_with_headings,2)
    Fcol=size(F_matrix_interp_with_headings,2);end
if Fcol<2
    Fcol=2;end
if Frow>size(F_matrix_interp_with_headings,1)
    Frow=size(F_matrix_interp_with_headings,1);end
if Frow<2
    Frow=2;end
Fmatrix(a,b)=F_matrix_interp_with_headings(Frow,Fcol);


% 6.2       MAKE f MATRIX 
fcol=l-3; %fcol=round(2*l-9); %to get the correct column in f
frow=2*0.5*round(2*(wed_i_to_e(a,b)-wed_s_to_i(a,b))/2)+42; %frow=2*0.5*round(2*(wed_i_to_e(a,b)-wed_s_to_i(a,b)))+25;
% 2.a Approximate for very large and small values of wed and l.
if fcol>size(f_little,2)
    fcol=size(f_little,2);
end
if fcol<2
    fcol=2;
end
if frow>size(f_little,1)
    frow=size(f_little,1);
end
if frow<2
    frow=2;
end
fmatrix(a,b)=f_little(frow,fcol);

% 6.3       MAKE TMR MATRIX 
depthmid=wed_tot(a,b)/2; %=(w/2)
depthoff=wed_s_to_i(a,b); % =(w/2 - d)
depthmid=round(depthmid*10)/10;
depthoff=round(depthoff*10)/10;
TPRdepthmid=depthmid*10+1; %this is to get correct values in the TPR matrix
TPRdepthoff=depthoff*10+1;
if TPRdepthoff<1; TPRdepthoff=1; end
if TPRdepthmid<1; TPRdepthmid=1; end
TMRratio(a,b)=TPR(TPRdepthoff,TPRl)/TPR(TPRdepthmid,TPRl);




        end
end



clear F_SP f_little TPR
clear  a b m n
%clear depthmid depthoff TPRdepthmid TPRdepthoff TPRl;
%clear wed_i_to_e wed_s_to_i wed_tot
clear wed_iso_to_EPID_TRANSP wed_source_to_iso_TRANSP wed_total_TRANSP

% end
CAX_Fmatrix=mean(mean(Fmatrix(189:196,253:268)));
CAX_epid=mean(mean(epid(189:196,253:268)));
CAX_SoverF=CAX_epid/CAX_Fmatrix
CAX_eclipse=mean(mean(eclipse(189:196,253:268)))
CAX_SoverD=CAX_epid/CAX_eclipse
CAX_mask=mean(mean(mask(189:196,253:268)))
CAX_TMR=mean(mean(TMRratio(189:196,253:268)))
CAX_fmatrix=mean(mean(fmatrix(189:196,253:268)))









% 12         CALCULATE DOSE USING CAX DATA ONLY
%DOSE_NOCORR=mask.*epid.*TMRratio.*fmatrix./Fmatrix*(FrameLossCorrFactor);
DOSE_NOCORR=epid.*TMRratio.*fmatrix./Fmatrix*(FrameLossCorrFactor);

DOSE_NOCORR(isnan(DOSE_NOCORR))=0;

figure; imagesc(eclipse); axis equal; axis tight; colorbar; title('TPS Dose'); 
figure; imagesc(DOSE_NOCORR); axis equal; axis tight;colorbar; title('EPID Dose, uncorrected'); 
CAX_D_NoCorr=mean2(DOSE_NOCORR(189:196,253:268))

return

% 11.        OFF-AXIS CORRECTION by CONVOLUTION

%   MAKE lin comb of GAUSSIANS
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


%   CONVOLUTION 1 - CROSS-PLANE DIRECTION


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

%   CONVOLUTION 2 - IN-PLANE DIRECTION

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



%DOSE_CONV=mask.*conv_2.*TMRratio.*fmatrix./Fmatrix*(FrameLossCorrFactor); 
DOSE_CONV=conv_2.*TMRratio.*fmatrix./Fmatrix*FrameLossCorrFactor; 
DOSE_CONV(isnan(DOSE_CONV))=0;
%this is actually OFF by a factor, with the correct shape. it's a temporary quantity

% Now, I KNOW I can trust the CAX value of DOSE_NOCORR, so let's shift DOSE_CONV
% so that it has the same CAX value as DOSE_NOCORR.
if mean(mean(eclipse(189:196,253:260)))>0.8*max(max(eclipse)) % if CAX is well in field
 DOSE_CONV=DOSE_CONV*mean(mean(DOSE_NOCORR(189:196,253:260)))/mean(mean(DOSE_CONV(189:196,253:260)));
else % if CAX is not in field (or is too close to field edge) do it in the centroid
    Ibw = im2bw(eclipse.*mask);
    Ibw = imfill(Ibw,'holes');
    Ilabel = bwlabel(Ibw);
    stat = regionprops(Ilabel,'centroid');
    figure; imagesc(eclipse); colorbar;  hold on
     axis equal; axis tight; title('Planned dose (TPS)'); colorbar; set(gca, 'CLim', [0.0*max(max(eclipse)) 1.1*max(max(eclipse))]);
          set(gca,'Xtick',[],'Ytick',[])
    for x = 1: numel(stat)
        centroid_col=round(stat(x).Centroid(1));
        centroid_row=round(stat(x).Centroid(2));
        plot(centroid_col,centroid_row,'ro');
    end
    DOSE_CONV=DOSE_CONV*mean(mean(DOSE_NOCORR((centroid_row-4):(centroid_row+4),(centroid_col-4):(centroid_col+4))))/...
    mean(mean(DOSE_CONV((centroid_row-4):(centroid_row+4),(centroid_col-4):(centroid_col+4))));
    
% tempNOCORR=sort(DOSE_NOCORR(:),'descend');
% tempNOCORR=mean(tempNOCORR(1:64));
% tempCONV=sort(DOSE_CONV(:),'descend');
% tempCONV=mean(tempCONV(1:64));
% DOSE_CONV=DOSE_CONV*tempNOCORR/tempCONV;
end


if ThisIsComissioning
    make_Gaussian_HornsCorrection
end

% LOAD empirical 2D shape correction of it
%eval(['load(''C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\RITE Dos 2015\',UnitStr,'\Gaussian_CAX_corr\',EnergyStr,'\ghc_l',l_string_ghc,'w',w_string,'.mat'');']);
eval(['load(''C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\RITE Dos 2015\',UnitStr,'\Gaussian_CAX_corr\',EnergyStr,'\ghc_l',l_big_string,'w',w_string,'.mat'');']);

% DOSE_CONV_2=DOSE_CONV*scalar;
% DOSE_CONV_3=DOSE_CONV_2./horns_corr;


DOSE_CONV_3=DOSE_CONV./horns_corr*scalar;
figure; imagesc(DOSE_CONV_3); colorbar
     axis equal; axis tight; title('Measured dose (EPID)'); colorbar; set(gca, 'CLim', [0.0*max(max(eclipse)) 1.1*max(max(eclipse))]); 
     set(gca,'Xtick',[],'Ytick',[])


%DOSE_CONV_3=DOSE_CONV./scaled_horns_corr;


%conv_2c=conv_2b./horns_corr;

% FINALLY RENORMALIZE SO THAT THE CONVOLVED MATRIX HAS SAME VALUE AS EPID (I.E.
% INITIAL VALUE) ON THE CAX
%conv_3=conv_2/mean(mean(conv_2(189:196,253:260)))*mean(mean(epid(189:196,253:260)));
%conv_3=conv_2c/mean(mean(conv_2(189:196,253:260)))*mean(mean(epid(189:196,253:260)));


% 14         CALCULATE DOSE WITH CONVOLUTION EDGE CORRECTION


%DOSE_CONV=mask.*conv_3.*TMRratio.*fmatrix./Fmatrix*frames_dropped_max_corr;



% DOSE_CONV_2=DOSE_CONV*scalar;
% 
% DOSE_CONV_3=DOSE_CONV_2./horns_corr;


%DOSE_CONV_3=mask.*conv_3.*TMRratio.*fmatrix./Fmatrix*frames_dropped_max_corr;




% 10.        OFF-AXIS CORRECTION METHOD 1: EMPIRICAL EDGE CORRECTION
% 10.1       ADAPT THE CORRECTION CURVES OBTAINED DURING COMISSIONING



corr_curve_left=padarray(corr_curve_left,500,1,'post');
corr_curve_right=padarray(corr_curve_right,500,1,'post');
corr_curve_top=padarray(corr_curve_top,500,1,'post');
corr_curve_bottom=padarray(corr_curve_bottom,500,1,'post');

corr_curve_right=flipud(corr_curve_right);
corr_curve_bottom=flipud(corr_curve_bottom);

% 10.2       TAKE INTO ACCOUNT COLLIMATOR ANGLE
% These following statements make the variable "coll" (which is between 0 and 45) from the value
% "collimator" which is between 270 and 90.  "Coll" is used for the edge correction.
if collimator>=0 && collimator<=45
    coll=collimator; end
if collimator>45 && collimator<=90
    coll=90-collimator; end
if collimator>=270 && collimator<315
    coll=collimator-270; end
if collimator>=315 && collimator<360
    coll=360-collimator; end

corr_curve_left(:,2)=0:size(corr_curve_left,1)-1;
corr_curve_left(:,3)=corr_curve_left(:,2)/cosd(coll);
for i=1:size(corr_curve_left,1)
    corr_curve_left(i,4)=interp1(corr_curve_left(:,3),corr_curve_left(:,1),corr_curve_left(i,2));
end
%Fcorredgeleft(:,1) is the edge curve with coll=0
%Fcorredgeleft(:,4) is the edge curve with coll=coll

corr_curve_right(:,2)=size(corr_curve_right,1)-1:-1:0;
corr_curve_right(:,3)=corr_curve_right(:,2)/cosd(coll);
for i=size(corr_curve_right,1):-1:1
    corr_curve_right(i,4)=interp1(corr_curve_right(:,3),corr_curve_right(:,1),corr_curve_right(i,2));
end

corr_curve_top(:,2)=0:size(corr_curve_top,1)-1;
corr_curve_top(:,3)=corr_curve_top(:,2)/cosd(coll);
for i=1:size(corr_curve_top,1)
    corr_curve_top(i,4)=interp1(corr_curve_top(:,3),corr_curve_top(:,1),corr_curve_top(i,2));
end
%Fcorredgetop(:,1) is the edge curve with coll=0
%Fcorredgetop(:,4) is the edge curve with coll=coll

corr_curve_bottom(:,2)=size(corr_curve_bottom,1)-1:-1:0;
corr_curve_bottom(:,3)=corr_curve_bottom(:,2)/cosd(coll);
for i=size(corr_curve_bottom,1):-1:1
    corr_curve_bottom(i,4)=interp1(corr_curve_bottom(:,3),corr_curve_bottom(:,1),corr_curve_bottom(i,2));
end

% %figure; plot(1:size(corr_curve_bottom,1),corr_curve_bottom(:,4),1:size(corr_curve_left,1),corr_curve_left(:,4),...
%     1:size(corr_curve_right,1),corr_curve_right(:,4)',1:size(corr_curve_top,1),corr_curve_top(:,4));
% legend('bottom','left','right','top','location','north'); title('Field-specific edge correction curves')

% 10.3       CALCULATE EDGE CORRECTIONS
%            along crossplane direction
Fcorr_CROSS=zeros(384,512);
for r=1:384
    [row,col] = find(mask(r,:));
    FcorredgeleftCROSS=padarray(corr_curve_left(:,4),min(col)-1,1,'pre');
    FcorredgeleftCROSS=FcorredgeleftCROSS(1:size(mask,2));
    FcorredgerightCROSS=padarray(corr_curve_right(:,4),[size(mask,2)-max(col)],1,'post');
    FcorredgerightCROSS=FcorredgerightCROSS(end-size(mask,2)+1:end);
    
    Fcorr_CROSS(r,:)=FcorredgeleftCROSS.*transpose(mask(r,:)).*FcorredgerightCROSS;
   clear FcorredgeleftCROSS FcorredgerightCROSS row col;
end
% %figure; imagesc(Fcorr_CROSS); axis equal; axis tight; title('Edge correction, crossplane'); colorbar; set(gca, 'CLim', [0.8 1.2]);

%            edge correction along inplane direction
Fcorr_IN=zeros(384,512);
for c=1:512
    [row,col] = find(mask(:,c));
    FcorredgetopIN=padarray(corr_curve_top(:,4),[min(row)-1],1,'pre');
    FcorredgetopIN=FcorredgetopIN(1:size(mask,1));
    FcorredgetopIN=transpose(FcorredgetopIN);
    FcorredgebottomIN=padarray(corr_curve_bottom(:,4),[size(mask,1)-max(row)],1,'post');
    FcorredgebottomIN=FcorredgebottomIN(end-size(mask,1)+1:end);
    FcorredgebottomIN=transpose(FcorredgebottomIN);
    
    Fcorr_IN(:,c)=FcorredgetopIN.*transpose(mask(:,c)).*FcorredgebottomIN;
   clear FcorredgeleftCOL FcorredgerightCOL row col;
end
% %figure; imagesc(Fcorr_IN); axis equal; axis tight; title('Edge correction, inplane'); colorbar; set(gca, 'CLim', [0.8 1.2]);
clear r c

F_edge_corrTot=Fcorr_CROSS .* Fcorr_IN.*mask; 
F_edge_corrTot=F_edge_corrTot/mean(mean(F_edge_corrTot(189:196,253:260)));
% %figure; imagesc(F_edge_corrTot); axis equal; axis tight; title('Edge correction, total'); colorbar; set(gca, 'CLim', [0.8 1.2]);
clear Fcorr_CROSS Fcorr_IN Fcorredgeleft Fcorredgeright FcorredgebottomIN FcorredgetopIN
clear corr_curve_bottom corr_curve_left corr_curve_right corr_curve_top





% 13         CALCULATE DOSE WITH EMPIRICAL EDGE CORRECTION
DOSE_EMPIRICAL=DOSE_NOCORR./(F_edge_corrTot+1e-10)*(FrameLossCorrFactor);
% (the "+1e-10" is to prevent 0/0=NaN)



% -------------------------------------------------------------------------
% RELATIVE DOSIMETRY OPTION
% UNCOMMENT THE FOLLOWING IF YOU WANT TO SET THE CALULCATED D(CAX) = TO TPS D(CAX)
% -------------------------------------------------------------------------
% CAX_D_factor_NOCORR=mean(mean(eclipse(188:197,252:261)))/mean(mean(DOSE_NOCORR(188:197,252:261)));
% CAX_D_factor_EMPIRICAL=mean(mean(eclipse(188:197,252:261)))/mean(mean(DOSE_EMPIRICAL(188:197,252:261)));
% CAX_D_factor_CONV=mean(mean(eclipse(188:197,252:261)))/mean(mean(DOSE_CONV(188:197,252:261)));
% DOSE_NOCORR=DOSE_NOCORR*CAX_D_factor_NOCORR;
% DOSE_EMPIRICAL=DOSE_EMPIRICAL*CAX_D_factor_EMPIRICAL;
% DOSE_CONV=DOSE_CONV*CAX_D_factor_CONV;
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% 14         PLOT 2D DOSE MAPS
%DOSEmax=max([mask.*eclipse(:);mask.*DOSE_NOCORR(:);mask.*DOSE_EMPIRICAL(:);mask.*DOSE_CONV_3(:)]);
DOSEmax=max(max([mask.*eclipse;mask.*DOSE_NOCORR;mask.*DOSE_CONV_3]));


% 14.1       TPS-PREDICTED
% figure; imagesc(eclipse.*mask); axis equal; axis tight; 
% colorbar; set(gca, 'CLim', [3*DOSEmax/4 DOSEmax]);
% title('TPS-predicted dose (cGy)');
% %clear eclipse_info
% % 14.2       EPID-CALCULATED, CAX ONLY
% figure; imagesc(DOSE_NOCORR); 
% title 'EPID-calculated Dose, F(CAX) only, masked (cGy)'
% axis equal; axis tight; 
% colorbar; set(gca, 'CLim', [3*DOSEmax/4 DOSEmax]);
% % 14.3       EPID-CALCULATED, EMPIRICAL EDGE CORRECTION
% figure; imagesc(DOSE_EMPIRICAL); 
% title 'EPID-calculated Dose, Edge-corrected, masked (cGy)'
% axis equal; axis tight; 
% colorbar; set(gca, 'CLim', [3*DOSEmax/4 DOSEmax]);
% % 14.4       EPID-CALCULATED, CONVOLUTION EDGE CORRECTION
% figure; imagesc(DOSE_CONV); 
% title 'EPID-calculated Dose, Convolution correction, masked (cGy)'
% axis equal; axis tight; 
% colorbar; set(gca, 'CLim', [3*DOSEmax/4 DOSEmax]);


% 16         PLOT SOME DOSE PROFILES
% 16.1       CROSS-PLANE
% figure; plot(1:512,eclipse(192,:),1:512,DOSE_NOCORR(192,:),1:512,DOSE_EMPIRICAL(192,:),1:512,DOSE_CONV_2(192,:),1:512,DOSE_CONV_3(192,:));
% legend('TPS','F(CAX) only','Empirical corr','Conv corr 2','Conv corr 3','location','South'); title('Cross-plane dose');xlim([1 512]);ylim([0.8*DOSEmax DOSEmax]);
% % % 16.2       IN-PLANE
% figure; plot((1:384),eclipse(:,256),(1:384),DOSE_NOCORR(:,256),(1:384),DOSE_EMPIRICAL(:,256),(1:384),DOSE_CONV_2(:,256),(1:384),DOSE_CONV_3(:,256));
% legend('TPS','F(CAX) only','Empirical corr','Convolution 2','Conv corr 3','location','South'); title('In-plane dose');xlim([1 512]);ylim([0.8*DOSEmax DOSEmax]);
% 16.1       NEGATIVE DIAGONAL
% x = [65 448]; y = [1 384]; [cx,cy,ProfDiagNeg_eclipse]=improfile(eclipse,x,y);
% x = [65 448]; y = [1 384]; [cx,cy,ProfDiagNeg_NoCorr]=improfile(DOSE_NOCORR,x,y);
% x = [65 448]; y = [1 384]; [cx,cy,ProfDiagNeg]=improfile(DOSE_EMPIRICAL,x,y);
% x = [65 448]; y = [1 384]; [cx,cy,ProfDiagNeg_conv]=improfile(DOSE_CONV,x,y);
% %figure; plot(-14.16284:0.073916228:14.16284,ProfDiagNeg_eclipse,-14.16284:0.073916228:14.16284,ProfDiagNeg_NoCorr,-14.16284:0.073916228:14.16284,ProfDiagNeg,-14.16284:0.073916228:14.16284,ProfDiagNeg_conv)
% legend('TPS','F(CAX) only','Empirical correction','Convolution correction','location','South'); title('Negative diagonal dose profile (cGy)'); xlabel('Distance from isocenter (cm)');
% clear x y cx cy ProfDiagNeg ProfDiagNeg_eclipse ProfDiagNeg_NoCorr ProfDiagNeg_conv
% % 16.1       POSITIVE DIAGONAL
% x = [65 448]; y = [384 1]; [cx,cy,ProfDiagPos_eclipse]=improfile(eclipse,x,y);
% x = [65 448]; y = [384 1]; [cx,cy,ProfDiagPos_NoCorr]=improfile(DOSE_NOCORR,x,y); 
% x = [65 448]; y = [384 1]; [cx,cy,ProfDiagPos]=improfile(DOSE_EMPIRICAL,x,y);
% x = [65 448]; y = [384 1]; [cx,cy,ProfDiagPos_conv]=improfile(DOSE_CONV,x,y);
% %figure; plot(-14.16284:0.073916228:14.16284,ProfDiagPos_eclipse,-14.16284:0.073916228:14.16284,ProfDiagPos_NoCorr,-14.16284:0.073916228:14.16284,ProfDiagPos,-14.16284:0.073916228:14.16284,ProfDiagPos_conv)
% legend('TPS','F(CAX) only','Empirical correction','Convolution correction','location','South'); title('Positive diagonal dose profile (cGy)'); xlabel('Distance from isocenter (cm)');
% clear x y cx cy ProfDiagPos ProfDiagPos_eclipse ProfDiagPos_NoCorr ProfDiagPos_conv



% 17         PLOT PERCENT DIFFERENCE BETWEEN TPS-PREDICTED DOSE AND EPID-CALCULATED DOSE
eclipse_max=max(max(eclipse));

% 17.1       F(CAX) only (no edge-correction), inside EPID mask
PercentDiffMatrix_NoCorr=zeros(384,512);
for c=1:384; 
        for d=1:512; 
            if mask(c,d)>0;
                PercentDiffMatrix_NoCorr(c,d)= ...
                    100*(DOSE_NOCORR(c,d)-eclipse(c,d))/eclipse_max;
            end
        end
end
clear c d;
%figure; imagesc(PercentDiffMatrix_NoCorr); title 'Percent difference, No off-axis correction'; axis equal; axis tight; colorbar; set(gca, 'CLim', [-10 10]);
PercentDiffCAX_NoCorr=mean(mean(PercentDiffMatrix_NoCorr(189:196,253:260)));

% 17.1       With empirical edge correction, inside EPID mask
PercentDiffMatrix_Empirical=zeros(384,512);
for c=1:384; 
    for d=1:512; 
            if mask(c,d)>0;
                PercentDiffMatrix_Empirical(c,d)= ...
                    100*(DOSE_EMPIRICAL(c,d)-eclipse(c,d))/eclipse_max;
            end
    end
end
clear c d;
%figure; imagesc(PercentDiffMatrix_Empirical); title 'Percent difference, Empirical correction';axis equal; axis tight; colorbar; set(gca, 'CLim', [-10 10]);
PercentDiffCAX_Corr=mean(mean(PercentDiffMatrix_Empirical(189:196,253:260)));

% 17.3      Convolution correction, inside EPID mask
PercentDiffMatrix_Conv=zeros(384,512);
for c=1:384; 
    for d=1:512; 
            if mask(c,d)>0;
                PercentDiffMatrix_Conv(c,d)= ...
                    100*(DOSE_CONV(c,d)-eclipse(c,d))/eclipse_max;
            end
    end
end
clear c d;



% 17.3      Convolution correction, inside EPID mask
% PercentDiffMatrix_Conv2=zeros(384,512);
% for c=1:384; 
%     for d=1:512; 
%             if mask(c,d)>0;
%                 PercentDiffMatrix_Conv2(c,d)= ...
%                     100*(DOSE_CONV_2(c,d)-eclipse(c,d))/eclipse_max;
%             end
%     end
% end
% clear c d;
%figure; imagesc(PercentDiffMatrix_Conv); title 'Percent difference, Convolution correction';axis equal; axis tight; colorbar; set(gca, 'CLim', [-10 10]);

PercentDiffMatrix_Conv3=100*mask.*(DOSE_CONV_3-eclipse)/eclipse_max;
all_figs(6)=figure; imagesc(PercentDiffMatrix_Conv3); title 'Percent difference, Convolution correction 3';axis equal; axis tight; colorbar; 
set(gca, 'CLim', [-15 15]); set(gcf,'position',[10 500 550 450])
     set(gca,'Xtick',[],'Ytick',[])
PercentDiffCAX_Conv3=mean(mean(PercentDiffMatrix_Conv3(189:196,253:260)));


clear F_edge_corrTot F_matrix_interp_with_headings  i xcr xin %corr_curve_bottom corr_curve_left corr_curve_right corr_curve_top

x_cr=-13.355:.05227:13.355;
x_in=-10.0155:.0523:10.0155;
% 
% fig01=figure;
% subtightplot(2,2,1,[.05,.01]); plot(x_cr,eclipse(192,:),x_cr,DOSE_NOCORR(192,:),x_cr,DOSE_EMPIRICAL(192,:),x_cr,DOSE_CONV(192,:),x_cr,DOSE_CONV_3(192,:));
% legend('TPS','F(CAX) only','Empirical','Gauss.Conv.','Gauss.Conv.New','location','Northeast'); title('Cross-plane dose (cGy)');ylim([.75*eclipse_max 1.1*eclipse_max]);xlim([-11 11]);%set(gca,'xtick',[]);
% subtightplot(2,2,2,[.05,.01]); plot(x_in,eclipse(:,256),x_in,DOSE_NOCORR(:,256),x_in,DOSE_EMPIRICAL(:,256),x_in,DOSE_CONV(:,256),x_in,DOSE_CONV_3(:,256));
% legend('TPS','F(CAX) only','Empirical','Gauss.Conv.','Gauss.Conv.New','location','Northeast'); title('In-plane dose (cGy)');ylim([.75*eclipse_max 1.1*eclipse_max]);xlim([-11 11]);set(gca,'ytick',[]);
% subtightplot(2,2,3); imagesc(PercentDiffMatrix_Empirical); title '% Diff.(1)Empirical(-10%,+10%)'
% axis equal; axis tight;  set(gca, 'CLim', [-10 10]);
% subtightplot(2,2,4); imagesc(PercentDiffMatrix_Conv3); title '(2)Gauss.Conv.New(-10%,+10%)'
% axis equal; axis tight;  set(gca, 'CLim', [-10 10]); set(gca,'ytick',[]);

% [Gamma,figGamma]=GammaEval2(eclipse,DOSE_CONV_3,3,3,mask);
% %[Gamma,figGamma]=GammaEval2(eclipse,DOSE_CONV,3,3,mask);
% GammaPassPercent=100-(100*length(find((Gamma.*mask)>1))/length(find(mask>0)))
% GammaMax=max(max(Gamma))
% GammaMean=mean(mean(Gamma))
% %find the 99th percentile value
% temp=sort(Gamma(:));
% index=round(.99*length(temp));
% GammaOnePercent=temp(index)

% eval(['save results_GA',ImAngStr,'_fx',FxStr,' DOSE_NOCORR DOSE_EMPIRICAL DOSE_CONV DOSE_CONV_3 epid mask_difference eclipse Gamma;']);
% eval(['saveas(fig01,''results_fig01_GA',ImAngStr,'_fx',FxStr,''',''fig'');']);
% eval(['saveas(fig01,''results_fig01_GA',ImAngStr,'_fx',FxStr,''',''jpg'');']);
% eval(['saveas(figGamma,''results_figGamma_GA',ImAngStr,'_fx',FxStr,''',''fig'');']);
% eval(['saveas(figGamma,''results_figGamma_GA',ImAngStr,'_fx',FxStr,''',''jpg'');']);


% eval(['DOSE_NOCORR_fx',FxStr,'=DOSE_NOCORR;']);
% eval(['DOSE_EMPIRICAL_fx',FxStr,'=DOSE_EMPIRICAL;']);
% eval(['DOSE_CONV_fx',FxStr,'=DOSE_CONV;']);
% eval(['epid_fx',FxStr,'=epid;']);
% eval(['mask_difference_fx',FxStr,'=mask_difference;']);
% 
%eval(['save results_GA',ImAngStr,'_fx',FxStr,' DOSE_NOCORR_fx',FxStr,' DOSE_EMPIRICAL_fx',FxStr,' DOSE_CONV_fx',FxStr,' epid_fx',FxStr,' mask_difference_fx',FxStr,' eclipse;']);

% 


pix=8; % width of square (in number of pixels) around the CAX to be averaged 
CAXrows=(384/2-pix/2+1):(384/2+pix/2);
CAXcols=(512/2-pix/2+1):(512/2+pix/2);
mean(mean(Fmatrix(CAXrows,CAXcols)))
mean(mean(fmatrix(CAXrows,CAXcols)))
mean(mean(TMRratio(CAXrows,CAXcols)))
mean(mean(epid(CAXrows,CAXcols)))
CAX_eclipse=mean(mean(eclipse(CAXrows,CAXcols)))
CAX_EpidNoCorr=mean(mean(DOSE_NOCORR(CAXrows,CAXcols)))
CAX_EpidConv3=mean(mean(DOSE_CONV_3(CAXrows,CAXcols)))

if not(ThisIsComissioning)
%     % FIGURES FOR PAPER
    set(0,'DefaultFigureWindowStyle','normal');  

    % CROSS-PLANE PROFILE
    [a,x1]=max(diff(eclipse(192,:)));
    [a,x2]=min(diff(eclipse(192,:)));
    y1=max(eclipse(192,:));
    all_figs(7)=figure; 
    plot(1:512,eclipse(192,:),1:512,DOSE_NOCORR(192,:),'g',1:512,DOSE_CONV(192,:),'c',1:512,DOSE_CONV_3(192,:),'r--');
    legend('TPS dose','D_E_P_I_D^C^A^X  (CAX only)','D_E_P_I_D^C^A^X\otimesG(sum) raw','D_E_P_I_D^C^A^X\otimesG(sum) corr','location','south'); 
    try; xlim([round(x1-20) round(x2+20)]); ylim([round(0.5*y1) round(1.5*y1)]); end
    xlabel('Crossplane pixel')
    ylabel('Dose (cGy)')
    set(gcf,'position',[0 100 500 500])
    axis square

    % IN-PLANE PROFILE
    [a,x3]=max(diff(eclipse(:,256)));
    [a,x4]=min(diff(eclipse(:,256)));
    y3=max(eclipse(:,256));
    all_figs(8)=figure; 
    plot(1:384,eclipse(:,256),1:384,DOSE_NOCORR(:,256),'g',1:384,DOSE_CONV(:,256),'c',1:384,DOSE_CONV_3(:,256),'r--');
    legend('TPS dose','D_E_P_I_D^C^A^X  (CAX only)','D_E_P_I_D^C^A^X\otimesG(sum) raw','D_E_P_I_D^C^A^X\otimesG(sum) corr','location','south'); 
    try; xlim([round(x3-20) round(x4+20)]); ylim([round(0.5*y3) round(1.5*y3)]); end
    xlabel('Inplane pixel')
    ylabel('Dose (cGy)')
    set(gcf,'position',[500 100 500 500])
    axis square

    
Gamma0503PassPercent=0;
Gamma1003PassPercent=0;
if DoGammaAnalysis
    Dose_TPS=eclipse;
    Dose_EPID=DOSE_CONV_3;
    Dose_pcdiff=PercentDiffMatrix_Conv3;
    [Gamma0503,all_figs(9)]=GammaEval2(Dose_TPS,Dose_EPID,5,3,mask);
    %how many pixels pass gamma analysis?
    Gamma0503PassPercent=100-(100*length(find((Gamma0503.*mask)>1))/length(find(mask>0)))
    GoodnessMetric1=length(find(abs(PercentDiffMatrix_Conv3)>10))/length(find(mask>0))*100; GoodnessMetric1=100-GoodnessMetric1;% Percentage of in-field points with DD>10%

    [Gamma1003,all_figs(9)]=GammaEval2(Dose_TPS,Dose_EPID,10,3,mask);
    %how many pixels pass gamma analysis?
    Gamma1003PassPercent=100-(100*length(find((Gamma1003.*mask)>1))/length(find(mask>0)))
  
    PerCentDoseDiffGreaterThan05=length(find(abs(PercentDiffMatrix_Conv3.*mask_eclipse80)>5))/length(find(mask_eclipse80>0))*100; % Percentage of in-field points with DD>10%
    PerCentDoseDiffGreaterThan10=length(find(abs(PercentDiffMatrix_Conv3.*mask_eclipse80)>10))/length(find(mask_eclipse80>0))*100;% Percentage of in-field points with DD>10%
    PerCentDoseDiffGreaterThan15=length(find(abs(PercentDiffMatrix_Conv3.*mask_eclipse80)>15))/length(find(mask_eclipse80>0))*100; % Percentage of in-field points with DD>10%
    PerCentDoseDiffGreaterThan20=length(find(abs(PercentDiffMatrix_Conv3.*mask_eclipse80)>20))/length(find(mask_eclipse80>0))*100; % Percentage of in-field points with DD>10%
    PerCentDoseDiffGreaterThan25=length(find(abs(PercentDiffMatrix_Conv3.*mask_eclipse80)>25))/length(find(mask_eclipse80>0))*100; % Percentage of in-field points with DD>10%
    PerCentDoseDiffGreaterThan30=length(find(abs(PercentDiffMatrix_Conv3.*mask_eclipse80)>30))/length(find(mask_eclipse80>0))*100; % Percentage of in-field points with DD>10%

RESULTS(Fractionloop,:)=[l w CAX_eclipse CAX_EpidNoCorr PercentDiffCAX_NoCorr CAX_EpidConv3 PercentDiffCAX_Conv3 GoodnessMetric1 Gamma0503PassPercent Gamma1003PassPercent];
RESULTS2(Fractionloop,:)=[l w CAX_Fmatrix CAX_epid CAX_SoverF CAX_eclipse CAX_SoverD CAX_mask CAX_TMR CAX_fmatrix];
RESULTS3(Fractionloop,:)=[PerCentDoseDiffGreaterThan05 PerCentDoseDiffGreaterThan10 PerCentDoseDiffGreaterThan15 PerCentDoseDiffGreaterThan20 PerCentDoseDiffGreaterThan25 PerCentDoseDiffGreaterThan30];

eval(['save(''Results_',ResolutionStr,'_',EnergyStr,'_GA',ImAngStr,'_fx',FxStr,'_L',l_string,'_w',w_string,'_05,10%_3mm'',''Dose_EPID'',''Dose_TPS'',''Dose_pcdiff'',''Gamma0503'',''Gamma1003'',''mask'',''RESULTS'',''RESULTS2'',''RESULTS3'');  ']);

finalfig=figure;
    set(gcf,'position',[100 100 1100 800])
subplot(3,3,1);
    imagesc(wed_tot);title 'Projected WED (cm)';axis equal; axis tight;  colorbar
    colormap('bone'); freezeColors; cbfreeze(colorbar);      set(gca,'Xtick',[],'Ytick',[])
subplot(3,3,2);
    imagesc(example_cine);title 'Middle cine'; axis equal; axis tight;  colorbar
    colormap('bone'); freezeColors; cbfreeze(colorbar);      set(gca,'Xtick',[],'Ytick',[])
subplot(3,3,3);
    plot(goodimages_numbers,CAX(goodimages_numbers),'go',badimages_numbers,CAX(badimages_numbers),'rx');
    title('CAX values of cines')
subplot(3,3,4);
    imagesc(Dose_EPID); title 'EPID dose (cGy)'; axis equal; axis tight;
    set(gca, 'CLim', [0 DOSEmax]);  colorbar
    colormap('jet'); freezeColors; cbfreeze(colorbar);      set(gca,'Xtick',[],'Ytick',[])
subplot(3,3,5);
    imagesc(Dose_TPS); title 'TPS dose (cGy)'; axis equal; axis tight;
    set(gca, 'CLim', [0 DOSEmax]); colorbar
    colormap('jet'); freezeColors; cbfreeze(colorbar);      set(gca,'Xtick',[],'Ytick',[])
subplot(3,3,6);
    imagesc(PercentDiffMatrix_Conv3); title 'Dose difference (-15%,+15%)'; axis equal; axis tight;
    set(gca, 'CLim', [-15 15]);
    colormap('jet'); freezeColors; cbfreeze(colorbar);      set(gca,'Xtick',[],'Ytick',[])
    xlabel(strcat(int2str(GoodnessMetric1),'% of in-field pixels have DD<10%'))

subplot(3,3,7);
    plot(1:512,eclipse(192,:),1:512,DOSE_NOCORR(192,:),'g',1:512,DOSE_CONV(192,:),'c',1:512,DOSE_CONV_3(192,:),'r--');
    %legend('TPS dose','D_E_P_I_D^C^A^X  (CAX only)','D_E_P_I_D^C^A^X\otimesG(sum) raw','D_E_P_I_D^C^A^X\otimesG(sum) corr','location','south'); 
    xlim([round(x1-50) round(x2+50)]); 
    ylim([round(0.6*y1) round(1.2*y1)]);
    ylabel('Dose (cGy)'); 
    title 'Dose profiles, cross-plane';
subplot(3,3,8);
    plot(1:384,eclipse(:,256),1:384,DOSE_NOCORR(:,256),'g',1:384,DOSE_CONV(:,256),'c',1:384,DOSE_CONV_3(:,256),'r--');
    %legend('TPS dose','D_E_P_I_D^C^A^X  (CAX only)','D_E_P_I_D^C^A^X\otimesG(sum) raw','D_E_P_I_D^C^A^X\otimesG(sum) corr','location','south'); 
    try; xlim([round(x3-50) round(x4+50)]); end
    try; ylim([round(0.6*y1) round(1.2*y1)]); end
    %ylabel('Dose (cGy)')
    title 'Dose profiles, in-plane';
subplot(3,3,9)
    imagesc(Gamma0503.*mask); axis equal; axis tight;
    set(gca, 'CLim', [0 2]);title 'Gamma (5%,3mm)'; 
    colormap([0 0 1;0 0.0322580635547638 0.967741906642914;0 0.0645161271095276 0.935483872890472;0 0.0967741906642914 0.903225779533386;0 0.129032254219055 0.870967745780945;0 0.161290317773819 0.838709652423859;0 0.193548381328583 0.806451618671417;0 0.225806444883347 0.774193525314331;0 0.25806450843811 0.74193549156189;0 0.290322571992874 0.709677398204803;0 0.322580635547638 0.677419364452362;0 0.354838699102402 0.645161271095276;0 0.387096762657166 0.612903237342834;0 0.419354826211929 0.580645143985748;0 0.451612889766693 0.548387110233307;0 0.483870953321457 0.516129016876221;0 0.516129016876221 0.483870953321457;0 0.548387110233307 0.451612889766693;0 0.580645143985748 0.419354826211929;0 0.612903237342834 0.387096762657166;0 0.645161271095276 0.354838699102402;0 0.677419364452362 0.322580635547638;0 0.709677398204803 0.290322571992874;0 0.74193549156189 0.25806450843811;0 0.774193525314331 0.225806444883347;0 0.806451618671417 0.193548381328583;0 0.838709652423859 0.161290317773819;0 0.870967745780945 0.129032254219055;0 0.903225779533386 0.0967741906642914;0 0.935483872890472 0.0645161271095276;0 0.967741906642914 0.0322580635547638;0 1 0;1 0 0;1 0.0322580635547638 0;1 0.0645161271095276 0;1 0.0967741906642914 0;1 0.129032254219055 0;1 0.161290317773819 0;1 0.193548381328583 0;1 0.225806444883347 0;1 0.25806450843811 0;1 0.290322571992874 0;1 0.322580635547638 0;1 0.354838699102402 0;1 0.387096762657166 0;1 0.419354826211929 0;1 0.451612889766693 0;1 0.483870953321457 0;1 0.516129016876221 0;1 0.548387110233307 0;1 0.580645143985748 0;1 0.612903237342834 0;1 0.645161271095276 0;1 0.677419364452362 0;1 0.709677398204803 0;1 0.74193549156189 0;1 0.774193525314331 0;1 0.806451618671417 0;1 0.838709652423859 0;1 0.870967745780945 0;1 0.903225779533386 0;1 0.935483872890472 0;1 0.967741906642914 0;1 1 0]);
    freezeColors; cbfreeze(colorbar);      set(gca,'Xtick',[],'Ytick',[])
    xlabel(strcat(int2str(Gamma0503PassPercent),'% of in-field pixels have \gamma<1'))
    

eval(['saveas(finalfig,''Results_',ResolutionStr,'_',EnergyStr,'_GA',ImAngStr,'_fx',FxStr,'_L',l_string,'_w',w_string,'_5%_3mm_FIGURES'',''jpg'')']);

end

end % of "if NOT this is comissioning
    if size(Fraction,2)>1
    close all
    end

    
 if abs(numImagesCorr-nCINEfiles)>=1
   warning('THE NUMBER OF IMAGES MAY NOT CORRESPOND THE INPUTTED MU VALUE!');
 end
