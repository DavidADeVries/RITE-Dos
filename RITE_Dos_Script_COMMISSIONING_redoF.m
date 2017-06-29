set(0,'DefaultFigureWindowStyle','docked'); %close all; %clear all
sprintf('Starting RITE Dos script')

% 1.        IMPORTANT PARAMETERS (CHECK THIS SECTION EVERY TIME!!)
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% STATE WHERE THE EPID IMAGES ARE, AND THE NUMBER OF THE FIRST AND LAST TO USE
EPID_folder='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014_08_19_F_calib_U9\EPID_calib_images'

%  start=9813
%  stop=start+35 %Unit 9 = +15(6X), +35(15X)
 %l=10 %field size
 %l_string='10p0'; %field size, l=5,10,15,20
 %w_string='10p0'; %solid water thickness simulated by appropriate depth, w=2.5,5,10,15,20,25,30,35cm
 %w_temp=10; %solid water thickness
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


collimator=0;
working_dir='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\RITE Dos 2015';

% STATE WHERE THE TPS IMAGE IS, AND THE FILE NAME
TPS_folder='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014_08_19_F_calib_U9\DOSE_from_Eclipse\15X_600RR';
eval(['TPS_dosemap_name=''l',l_string,'w',w_string,'.dcm'';']);

% 5.        IMPORT ECLIPSE IMAGE
cd(TPS_folder)
eclipse=dicomread(TPS_dosemap_name); 
eclipse_info=dicominfo(TPS_dosemap_name); 
eclipse=double(eclipse);
eclipse=100*eclipse*eclipse_info.DoseGridScaling;

% 3.        MAKE AN EPID IMAGE FROM RAW CINE IMAGES
cd(EPID_folder);
[epid,flood_old,flood_new]=EPID_prepare_COMMISSIONING(start,stop);
cd(working_dir);


% LOAD WEIGHTINGS OF GAUSSIAN CURVES TO MODEL EDGE BY CONVOLUTION
eval(['load(''C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\RITE Dos 2015\Gaussian_weights\',EnergyStr,'\gw_l',l_string,'w',w_string,'.mat'');']);
% If you get an error saying there is no such file, make it using comissioning
% square fields and the script
% make_Gaussian_weights.m


% LOAD COMISSIONING DATA
eval(['load(''C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\RITE Dos 2015\comissioning_data\F_matrix_interp_with_headings_',UnitStr,'_',EnergyStr,'.mat'');']);
eval(['load(''C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\RITE Dos 2015\comissioning_data\f_little_',UnitStr,''');']); %measured with 06X
eval(['load(''C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\RITE Dos 2015\comissioning_data\TPR_',EnergyStr,''');']);



% 2.        CORRECT THE CALCULATED WEDS (OPTIONAL. BUT CHECK EVERY TIME!))

% THIS IS BECAUSE WE ARE WORKING WITH SOLID WATER BLOCKS
wed_s_to_i=zeros(384,512)+w_temp/2+0.3;
wed_i_to_e=zeros(384,512)+w_temp/2+0.3;
wed_tot=zeros(384,512)+w_temp+0.6;

wed_CAX_corr=[mean(mean(wed_s_to_i(189:196,253:260))) ...
    mean(mean(wed_i_to_e(189:196,253:260))) ...
    mean(mean(wed_tot(189:196,253:260)))]



% 4.        ACCOUNT FOR THE DIFFERENT FLOOD FIELD

% % The F(CAX) calibration of August 2014 on U9 was done with EPID images that where re-zeroed
% % but not FF-corr-removed. Now I want to use FF-corr-removed images, therefore to use that F(CAX) I need to multiply by
% % flood(CAX)/flood_mean
% flood=dicomread('C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014_07to12_DF_FF_images\20140818\MFF07645.dcm');
% F_matrix_interp_with_headings=F_matrix_interp_with_headings*mean(mean(flood(188:197,252:261)))/mean(mean(flood(:)));
% clear flood
% NOTE: The F(CAX) calibration of August 2014 on U9 was done with EPID images that where re-zeroed
% but were still corrected with the old (non-flat) FF, therefore to use that F(CAX) I need to divide the final EPID image by
% (flood(CAX)/flood_mean)*(flood_new_mean/flood_new(CAX))
% Flood_F_factor=(mean(mean(flood_old(189:196,253:260)))/mean(mean(flood_old(:))))*(mean(mean(flood_new(:)))/mean(mean(flood_new(189:196,253:260))));
Flood_F_factor=1 % for 15X

 
% 6.        MAKE F, f, TMR MATRICES

% You loaded the variable F_matrix_interp_with_headings(132x37) which comes from 
% cubic interpolations of measured values on your unit. 
% Columns are field sizes (l) from 2.5cm to 20cm in steps of 0.5cm.
% Rows are equivalent water depth (wed; from source to EPID) 3.1cm to 25.6cm in steps of 0.25cm
Fmatrix=zeros(384,512);

%You loaded the variable f(21x11) which comes from linear interp 
%and then interp1 of data from March 26 2013 U9 (Stefano).
%cols are equiv sq field sizes 5*5 to 24*24 in steps of 0.5 cm^2
%rows are displacement d from midpoint from -12 to 12 in steps of 0.5cm
fmatrix=zeros(384,512);

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
fcol=2*l-9; %to get the correct column in f
frow=2*0.5*round(2*(wed_i_to_e(a,b)-wed_s_to_i(a,b)))+25;
% 2.a Approximate for very large and small values of wed and l.
if fcol>40
    fcol=40;
end
if fcol<1
    fcol=1;
end
if frow>50
    frow=50;
end
if frow<1
    frow=1;
end
fmatrix(a,b)=f_SP_2(frow,fcol);

% 6.3       MAKE TMR MATRIX 
depthmid=(wed_tot(a,b))/2; %=(w/2)
depthoff=wed_s_to_i(a,b); % =(w/2 - d)
depthmid=round(depthmid*10)/10;
depthoff=round(depthoff*10)/10;
TPRdepthmid=depthmid*10+1; %this is to get correct values in the TPR matrix
TPRdepthoff=depthoff*10+1;
TMRratio(a,b)=TPR(TPRdepthoff,TPRl)/TPR(TPRdepthmid,TPRl);
        end
end
clear F_SP f_SP_2 TPR
clear Fcol Frow fcol frow a b m n
clear depthmid depthoff TPRdepthmid TPRdepthoff TPRl;
clear wed_i_to_e wed_s_to_i wed_tot
clear wed_iso_to_EPID_TRANSP wed_source_to_iso_TRANSP wed_total_TRANSP
 

% 7.        MAKE A BINARY MASK OF FIELD USING EPID IMAGE
mask=zeros(384,512);
epid_center_mean=mean(mean(epid(188:197,252:261)));
epid_outer_mean=mean(mean(epid(1:10,1:10))); 
% NOTE: WE ARE ASSUMING THAT CAX IS IN FIELD AND TOP-LEFT CORNER OF EPID IS OUT
for a=1:384
    for b=1:512
        if epid(a,b)>abs(epid_center_mean+epid_outer_mean)/2;
           mask(a,b)=1;
        end
    end
end
clear a b epid_center_mean epid_outer_mean;
% figure; imagesc(mask); colormap('bone')
% title 'mask, from EPID image'
% axis equal; axis tight; 
% colorbar; set(gca, 'CLim', [0 1]);


% 8.        MAKE A BINARY MASK OF FIELD USING TPS IMAGE
mask_eclipse=zeros(384,512);
eclipse_center_mean=mean(mean(eclipse(188:197,252:261)));
eclipse_outer_mean=mean(mean(eclipse(1:10,1:10)));
% NOTE: WE ARE ASSUMING THAT CAX IS IN FIELD AND TOP-LEFT CORNER OF EPID IS OUT
for a=1:384
    for b=1:512
        if eclipse(a,b)>abs(eclipse_center_mean+eclipse_outer_mean)/2;
           mask_eclipse(a,b)=1;
        end
    end
end
clear a b eclipse_center_mean eclipse_outer_mean;
% figure; imagesc(mask_eclipse); colormap('bone')
% title 'mask, from Eclipse image'
% axis equal; axis tight; 
% colorbar; set(gca, 'CLim', [0 1]);


% 9.        PLOT INTERSECTION OF THE TWO MASKS ABOVE (THIS WILL AFFECT YOUR FINAL PERCENT
% DIFF MAP. IN OTHER WORDS, IT affects YOUR TPS MAP / EPID MAP DISCORDANCE DUE TO EPID SAG.)
mask_difference=mask-mask_eclipse;
figure; imagesc(mask_difference); 
title 'masks intersection (+1=EPID only, -1=TPS only)'
axis equal; axis tight; 
colorbar; set(gca, 'CLim', [-1 1]);




% 12         CALCULATE DOSE USING CAX DATA ONLY
DOSE_NOCORR=mask.*epid.*TMRratio.*fmatrix./Fmatrix/Flood_F_factor;




% 11.        OFF-AXIS CORRECTION METHOD 2: CONVOLUTION

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
conv_1=zeros(384,512);
for row=1:384;
    
%   GIVE THEM RELATIVE WEIGHTS
    gsum=w_cr_tot(row,1)*g1+w_cr_tot(row,2)*g2+w_cr_tot(row,3)*g3+w_cr_tot(row,4)*g4;
    %figure; plot(x,g1,x,g2,x,g3,x,g4,x,gsum); legend('Gaussian 1','Gaussian 2','Gaussian 3','Gaussian 4','Sum'); xlim([100 412]); %ylim([0 0.1])

    profile=epid(row,:)/trapz(epid(row,:));
    conv_1(row,:)=conv(profile,gsum,'same');
    
    % Now that I gave correct shape, I must renormalize to the correct height.
    % Do this by finding the midway point along this cross plane profile and
    % renormalize there. But if no points along this row are in the field, then
    % set the whole row to zeros
    
    first=min(find(mask(row,:)));
    last=max(find(mask(row,:)));
    mid=first+round((last-first)/2);
    
    if mid>1
        temp_post_conv=conv_1(row,:);
        temp_pre_conv=epid(row,:);
        conv_1(row,:)=conv_1(row,:)/mean(temp_post_conv(mid-4:mid+4))*mean(temp_pre_conv(mid-4:mid+4));  
    else
        conv_1(row,:)=zeros(1,512);
    end
       
end
%conv_1=conv_1/mean(mean(conv_1(189:196,253:260)));
clear row temp_corr temp_epid epid_profile
clear first last mid

%   CONVOLUTION 2 - IN-PLANE DIRECTION
conv_2=zeros(384,512);
for col=1:512;
%   GIVE THEM RELATIVE WEIGHTS
    gsum=w_in_tot(1,col)*g1+w_in_tot(2,col)*g2+w_in_tot(3,col)*g3+w_in_tot(4,col)*g4;
    %figure; plot(x,g1,x,g2,x,g3,x,g4,x,gsum); legend('Gaussian 1','Gaussian 2','Gaussian 3','Gaussian 4','Sum'); xlim([100 412]); %ylim([0 0.1])

    profile=conv_1(:,col)/trapz(conv_1(:,col));
    conv_2(:,col)=conv(profile,gsum,'same');
    
    % Now that I gave correct shape, I must renormalize to the correct height.
    % Do this by finding the midway point along this cross plane profile and
    % renormalize there.
    
    first=min(find(mask(:,col)));
    last=max(find(mask(:,col)));
    mid=first+round((last-first)/2);
    
    if mid>1
        temp_post_conv=conv_2(:,col);
        temp_pre_conv=conv_1(:,col);
        conv_2(:,col)=conv_2(:,col)/mean(temp_post_conv(mid-4:mid+4))*mean(temp_pre_conv(mid-4:mid+4));  
    else
        conv_2(:,col)=transpose(zeros(1,384));
    end
    
end
clear col temp_corr temp_epid epid_profile

clear g1 g2 g3 g4 gsum
clear w_cr_tot w_in_tot


% 14         CALCULATE DOSE WITH CONVOLUTION EDGE CORRECTION
DOSE_CONV=mask.*conv_2.*TMRratio.*fmatrix./Fmatrix/Flood_F_factor;




% 10.        OFF-AXIS CORRECTION METHOD 1: EMPIRICAL EDGE CORRECTION
% 10.1       ADAPT THE CORRECTION CURVES OBTAINED DURING COMISSIONING

% LOAD EMPIRICAL EDGE CORRECTION CURVES FOR OFF-AXIS CORRECTION. THESE CORRECT FOR BOTH THE S/D VARIABILITY CLOSE TO EDGE, AND FOR PROFILE
% SHAPE OFF-AXIS (HORNS, NEGATIVE HORNS, AND NON-FLATNESS DUE TO DIFFERENTIAL ENERGY SENSITIVITY OF THE EPID)
eval(['load(''C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\RITE Dos U9 2015\empirical_corr\cc_l',l_string,'w',w_string,'.mat'');']);
% If you get an error saying there is no such file, make it using comissioning
% square fields and the script
% make_empirical_corr.m

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

figure; plot(1:size(corr_curve_bottom,1),corr_curve_bottom(:,4),1:size(corr_curve_left,1),corr_curve_left(:,4),...
    1:size(corr_curve_right,1),corr_curve_right(:,4)',1:size(corr_curve_top,1),corr_curve_top(:,4));
legend('bottom','left','right','top','location','north'); title('Field-specific edge correction curves')

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
% figure; imagesc(Fcorr_CROSS); axis equal; axis tight; title('Edge correction, crossplane'); colorbar; set(gca, 'CLim', [0.8 1.2]);

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
% figure; imagesc(Fcorr_IN); axis equal; axis tight; title('Edge correction, inplane'); colorbar; set(gca, 'CLim', [0.8 1.2]);
clear r c

F_edge_corrTot=Fcorr_CROSS .* Fcorr_IN.*mask; 
F_edge_corrTot=F_edge_corrTot/mean(mean(F_edge_corrTot(189:196,253:260)));
figure; imagesc(F_edge_corrTot); axis equal; axis tight; title('Edge correction, total'); colorbar; set(gca, 'CLim', [0.8 1.2]);
clear Fcorr_CROSS Fcorr_IN Fcorredgeleft Fcorredgeright FcorredgebottomIN FcorredgetopIN
clear corr_curve_bottom corr_curve_left corr_curve_right corr_curve_top





% 13         CALCULATE DOSE WITH EMPIRICAL EDGE CORRECTION
DOSE_EMPIRICAL=mask.*epid.*TMRratio.*fmatrix./Fmatrix/Flood_F_factor./(F_edge_corrTot+1e-10);
% (the "+1e-10" is to prevent 0/0=NaN)


DOSEmax=max([eclipse(:);DOSE_NOCORR(:);DOSE_EMPIRICAL(:);DOSE_CONV(:)])

% 14.b        CORRECT DOSE CONV with pre-calculated correction MATRIX
eval(['load(''C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\RITE Dos U9 2015\Backscatter_corr\bsc_l',l_string,'w',w_string,'.mat'');']);
% If you get an error saying there is no such file, make it using
% make_2D_backscatter_corr.m. Then come back and re-run this.
DOSE_CONV_bsc=mask.*DOSE_CONV./backscatter_corr;

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% TEMP: MODIFY DOSE MAP TO MATCH ECLIPSE AT CAX TO ACCOUNT FOR OUTPUT CHANGES.
% THIS IS OBVIOUSLY TEMORARY, TO FIX OTHER ISSUES! (I.E. WE'RE DOING RELATIVE
% DOSIMETRY NOW!
% CAD_D_factor_NOCORR=mean(mean(eclipse(188:197,252:261)))/mean(mean(DOSE_NOCORR(188:197,252:261)));
% DOSE_NOCORR=DOSE_NOCORR*CAD_D_factor_NOCORR;
% 
% CAX_D_factor_EMPIRICAL=mean(mean(eclipse(188:197,252:261)))/mean(mean(DOSE_EMPIRICAL(188:197,252:261)));
% DOSE_EMPIRICAL=DOSE_EMPIRICAL*CAX_D_factor_EMPIRICAL;
% 
% CAX_D_factor_CONV=mean(mean(eclipse(188:197,252:261)))/mean(mean(DOSE_CONV(188:197,252:261)));
% DOSE_CONV=DOSE_CONV*CAX_D_factor_CONV;
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% 14         PLOT 2D DOSE MAPS

% 14.1       TPS-PREDICTED
figure; imagesc(eclipse.*mask); axis equal; axis tight; 
colorbar; set(gca, 'CLim', [3*DOSEmax/4 DOSEmax]);
title('TPS-predicted dose (cGy)');
clear eclipse_info
% 14.2       EPID-CALCULATED, CAX ONLY
figure; imagesc(DOSE_NOCORR); 
title 'EPID-calculated Dose, F(CAX) only, masked (cGy)'
axis equal; axis tight; 
colorbar; set(gca, 'CLim', [3*DOSEmax/4 DOSEmax]);
% 14.3       EPID-CALCULATED, EMPIRICAL EDGE CORRECTION
figure; imagesc(DOSE_EMPIRICAL); 
title 'EPID-calculated Dose, Edge-corrected, masked (cGy)'
axis equal; axis tight; 
colorbar; set(gca, 'CLim', [3*DOSEmax/4 DOSEmax]);
% 14.4       EPID-CALCULATED, CONVOLUTION EDGE CORRECTION
figure; imagesc(DOSE_CONV); 
title 'EPID-calculated Dose, Convolution correction, masked (cGy)'
axis equal; axis tight; 
colorbar; set(gca, 'CLim', [3*DOSEmax/4 DOSEmax]);
% 14.4       EPID-CALCULATED, CONVOLUTION EDGE CORRECTION, BSC CORRECTED
figure; imagesc(DOSE_CONV_bsc); 
title 'EPID-calculated Dose, Convolution correction, masked, bsc (cGy)'
axis equal; axis tight; 
colorbar; set(gca, 'CLim', [3*DOSEmax/4 DOSEmax]);

% 16         PLOT SOME DOSE PROFILES
% 16.1       CROSS-PLANE
figure; 
plot(1:512,eclipse(192,:),1:512,DOSE_NOCORR(192,:),1:512,DOSE_EMPIRICAL(192,:),1:512,DOSE_CONV(192,:));
legend('TPS','F(CAX) only','Empirical correction','Convolution correction','location','South'); title('Cross-plane dose');xlim([1 512]);ylim([0 DOSEmax]);
% 16.2       IN-PLANE
figure; 
plot((1:384)+64,eclipse(:,256),(1:384)+64,DOSE_NOCORR(:,256),(1:384)+64,DOSE_EMPIRICAL(:,256),(1:384)+64,DOSE_CONV(:,256));
legend('TPS','F(CAX) only','Empirical correction','Convolution correction','location','South'); title('In-plane dose');xlim([1 512]);ylim([0 DOSEmax]);
% 16.1       NEGATIVE DIAGONAL
x = [65 448]; y = [1 384]; [cx,cy,ProfDiagNeg_eclipse]=improfile(eclipse,x,y);
x = [65 448]; y = [1 384]; [cx,cy,ProfDiagNeg_NoCorr]=improfile(DOSE_NOCORR,x,y);
x = [65 448]; y = [1 384]; [cx,cy,ProfDiagNeg]=improfile(DOSE_EMPIRICAL,x,y);
x = [65 448]; y = [1 384]; [cx,cy,ProfDiagNeg_conv]=improfile(DOSE_CONV,x,y);
figure; plot(-14.16284:0.073916228:14.16284,ProfDiagNeg_eclipse,-14.16284:0.073916228:14.16284,ProfDiagNeg_NoCorr,-14.16284:0.073916228:14.16284,ProfDiagNeg,-14.16284:0.073916228:14.16284,ProfDiagNeg_conv)
legend('TPS','F(CAX) only','Empirical correction','Convolution correction','location','South'); title('Negative diagonal dose profile (cGy)'); xlabel('Distance from isocenter (cm)');
clear x y cx cy ProfDiagNeg ProfDiagNeg_eclipse ProfDiagNeg_NoCorr ProfDiagNeg_conv
% 16.1       POSITIVE DIAGONAL
x = [65 448]; y = [384 1]; [cx,cy,ProfDiagPos_eclipse]=improfile(eclipse,x,y);
x = [65 448]; y = [384 1]; [cx,cy,ProfDiagPos_NoCorr]=improfile(DOSE_NOCORR,x,y); 
x = [65 448]; y = [384 1]; [cx,cy,ProfDiagPos]=improfile(DOSE_EMPIRICAL,x,y);
x = [65 448]; y = [384 1]; [cx,cy,ProfDiagPos_conv]=improfile(DOSE_CONV,x,y);
figure; plot(-14.16284:0.073916228:14.16284,ProfDiagPos_eclipse,-14.16284:0.073916228:14.16284,ProfDiagPos_NoCorr,-14.16284:0.073916228:14.16284,ProfDiagPos,-14.16284:0.073916228:14.16284,ProfDiagPos_conv)
legend('TPS','F(CAX) only','Empirical correction','Convolution correction','location','South'); title('Positive diagonal dose profile (cGy)'); xlabel('Distance from isocenter (cm)');
clear x y cx cy ProfDiagPos ProfDiagPos_eclipse ProfDiagPos_NoCorr ProfDiagPos_conv



% 17         PLOT PERCENT DIFFERENCE BETWEEN TPS-PREDICTED DOSE AND EPID-CALCULATED DOSE

% 17.1       F(CAX) only (no edge-correction), inside EPID mask
PercentDiffMatrix_NoCorr=zeros(384,512);
for c=1:384; 
        for d=1:512; 
            if mask(c,d)>0;
                PercentDiffMatrix_NoCorr(c,d)= ...
                    100*(DOSE_NOCORR(c,d)-eclipse(c,d))/eclipse(c,d);
            end
    end
end
clear c d;
figure; imagesc(PercentDiffMatrix_NoCorr); title 'Percent difference, No off-axis correction'
axis equal; axis tight; colorbar; set(gca, 'CLim', [-5 5]);
PercentDiffCAX_NoCorr=mean(mean(PercentDiffMatrix_NoCorr(189:196,253:260)));

% 17.1       With empirical edge correction, inside EPID mask
PercentDiffMatrix_Empirical=zeros(384,512);
for c=1:384; 
        for d=1:512; 
            if mask(c,d)>0;
                PercentDiffMatrix_Empirical(c,d)= ...
                    100*(DOSE_EMPIRICAL(c,d)-eclipse(c,d))/eclipse(c,d);
            end
    end
end
clear c d;
figure; imagesc(PercentDiffMatrix_Empirical); title 'Percent difference, Empirical correction'
axis equal; axis tight; colorbar; set(gca, 'CLim', [-5 5]);
PercentDiffCAX_Corr=mean(mean(PercentDiffMatrix_Empirical(189:196,253:260)));

% 17.3      Convolution correction, inside EPID mask
PercentDiffMatrix_Conv=zeros(384,512);
for c=1:384; 
        for d=1:512; 
            if mask(c,d)>0;
                PercentDiffMatrix_Conv(c,d)= ...
                    100*(DOSE_CONV(c,d)-eclipse(c,d))/eclipse(c,d);
            end
    end
end
clear c d;
figure; imagesc(PercentDiffMatrix_Conv); title 'Percent difference, Convolution correction'
axis equal; axis tight; colorbar; set(gca, 'CLim', [-5 5]);
PercentDiffCAX_Conv=mean(mean(PercentDiffMatrix_Conv(189:196,253:260)));

% 17.3      Convolution correction, inside EPID mask, bsc 
PercentDiffMatrix_Conv_bsc=zeros(384,512);
for c=1:384; 
        for d=1:512; 
            if mask(c,d)>0;
                PercentDiffMatrix_Conv_bsc(c,d)= ...
                    100*(DOSE_CONV_bsc(c,d)-eclipse(c,d))/eclipse(c,d);
            end
    end
end
clear c d;
figure; imagesc(PercentDiffMatrix_Conv_bsc); title 'Percent difference, Convolution correction'
axis equal; axis tight; colorbar; set(gca, 'CLim', [-5 5]);
PercentDiffCAX_Conv_bsc=mean(mean(PercentDiffMatrix_Conv_bsc(189:196,253:260)));

% clear F_edge_corrTot F_matrix_interp_with_headings F_matrix_norm Fmatrix TMRratio collimator fmatrix i xcr xin %corr_curve_bottom corr_curve_left corr_curve_right corr_curve_top

% CAD_D_factor_NOCORR
% CAX_D_factor_EMPIRICAL
% CAX_D_factor_CONV


