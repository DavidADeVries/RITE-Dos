function[image_sum,flood_00cm,flood_new]=EPID_prepare_PATIENT(dir_CINE,FF_used,FF_new)
set(0,'DefaultFigureWindowStyle','docked');
close all

% CHANGE AS NEEDED
% these are the FLOOD FIELD and DARK FIELD that were used at the moment of image
% aqcuisition
% -------------------------------------------------------------------------
flood_00cm=dicomread(FF_used);

%flood_00cm=dicomread('C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\DF_FF_images\20061209\MFF00036.dcm');%U9
%flood_00cm=dicomread('C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\DF_FF_images\20140716\MFF07263.dcm');%U9
%flood_00cm=dicomread('C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\DF_FF_images\20140818\MFF07643.dcm');%U9

%dark=dicomread('C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\DF_FF_images\20070419\MDF00247.dcm');%U9
%dark=dicomread('C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\DF_FF_images\20140716\MDF07262.dcm');%U9
%dark=dicomread('C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\DF_FF_images\20140818\MDF07642.dcm');%U9

% These are the FF that you may choose to apply, after having removed the one
% used during acquisition. They are taken through XXcm of solid water.
% -------------------------------------------------------------------------
flood_10cm=dicomread('C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014_09_24_U9_EPID_tests\MFF13225.dcm');
%flood_20cm=dicomread('C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014_10_21\MFF13409.dcm');
flood_20cm=dicomread(FF_new);

new_flood_field_correction='flood_20cm'; 
%Choose 20cm if you want to artificially 'flatten' your EPID image taken through 20cm of tissue.
%This is a good idea because it creates a correspondance through a 'flat' EPID
%image at 20cm depth, and a 'flat' dose profile at mid-depth, or 10cm (the
%flattening filter is designed to flatten as mich as possible at 10cm). So you
%get a better corresponance between S and D off-axis
% -------------------------------------------------------------------------

flood_all_min=min([flood_00cm(:);flood_10cm(:);flood_20cm(:)]);
flood_all_max=max([flood_00cm(:);flood_10cm(:);flood_20cm(:)]);
flood_00cm_max=max(flood_00cm(:));
flood_10cm_max=max(flood_10cm(:));
flood_20cm_max=max(flood_20cm(:));
flood_profiles_min=min(min([flood_00cm(:,256);flood_10cm(:,256);flood_20cm(:,256)]),min([transpose(flood_00cm(192,:));transpose(flood_10cm(192,:));transpose(flood_20cm(192,:))]));
flood_profiles_max=max(max([flood_00cm(:,256);flood_10cm(:,256);flood_20cm(:,256)]),max([transpose(flood_00cm(192,:));transpose(flood_10cm(192,:));transpose(flood_20cm(192,:))]));


flood_00cm=double(flood_00cm);
flood_00cm_mean=mean(mean(flood_00cm(:)));
% figure; imagesc(flood_00cm); axis equal; axis tight; title('Flood Field used during image acquisition. (2014/08/18, U9, avg 30 frames'); colorbar; set(gca, 'CLim', [flood_00cm_max-1400 flood_00cm_max-400]);
% figure; plot(1:512,flood_00cm(192,:),'.-',((1:384)+64),flood_00cm(:,256),'.-'); xlim([0 512]); ylim([4500 5300]);
% title('Flood field profiles (0cm)'); legend('cross-plane','in-plane','location','north')

flood_10cm=double(flood_10cm);
flood_10cm_mean=mean(mean(flood_10cm(:)));
% figure; imagesc(flood_10cm); axis equal; axis tight; title('New Flood Field image (10cm depth), Sept 24 2014, U9, avg of 30 frames'); colorbar; set(gca, 'CLim', [flood_10cm_max-1000 flood_10cm_max]);
% figure; plot(1:512,flood_10cm(192,:),'.-',((1:384)+64),flood_10cm(:,256),'.-'); xlim([0 512]);  ylim([2300 3500]);set(gca, 'CLim', [flood_all_min flood_all_max]);
% title('New flood field profiles (10cm)'); legend('cross-plane','in-plane','location','north')

flood_20cm=double(flood_20cm);
flood_20cm_mean=mean(mean(flood_20cm(:)));
% figure; imagesc(flood_20cm); axis equal; axis tight; title('New Flood Field image (20cm depth), Oct 21 2014, U9, avg of 30 frames'); colorbar; set(gca, 'CLim', [flood_20cm_max-1000 flood_20cm_max]);
% figure; plot(1:512,flood_20cm(192,:),'.-',((1:384)+64),flood_20cm(:,256),'.-'); xlim([0 512]);  ylim([1000 2200]);set(gca, 'CLim', [flood_all_min flood_all_max]);
% title('New flood field profiles (20cm)'); legend('cross-plane','in-plane','location','north')

% profiles of all 3 flood fields together
% figure, plot(1:512,flood_00cm(192,:),'-b',((1:384)+64),flood_00cm(:,256),'-g',1:512,flood_10cm(192,:),'-.b',((1:384)+64),flood_10cm(:,256),'-.g',...
%     1:512,flood_20cm(192,:),'--b',((1:384)+64),flood_20cm(:,256),'--g'); xlim([0 512]); ylim([flood_profiles_min flood_profiles_max]);
% title('Flood field profiles'); 
% legend('0cm, cross-plane','0cm in-plane','10cm, cross-plane','10cm in-plane','20cm, cross-plane','20cm in-plane','location','east')

%dark=double(dark);
% figure; imagesc(dark); axis equal; axis tight; title('Dark Field image, Aug 18 2014, U9, avg of 30 frames'); colorbar; % set(gca, 'CLim', [ ]);
% figure; plot(1:512,dark(192,:),'.-',((1:384)+64),dark(:,256),'.-'); xlim([0 512]); title('Dark field profiles'); legend('cross-plane','in-plane')

eval(['flood_new=',new_flood_field_correction,';'])
flood_new_mean=mean(mean(flood_new(:)));



%image_sum=zeros(768,1024);
image_sum=zeros(384,512);

cd(dir_CINE);

CINEfilenames=dir('*.dcm');  %Make List of dicom filenames in folder
nCINEfiles=length(CINEfilenames); %Number of dicom files in folder


for n=1:nCINEfiles
currentfilename=CINEfilenames(n).name;
image_asis=dicomread(currentfilename);
image_asis=double(image_asis);

if n==1
    if size(image_asis,2)==512
    flood_new=imresize(flood_new,0.50);
    end
end

% PLOT THE RAW CENTERMOST CINE FRAME
% if n==round(nCINEfiles/2)
% figure; imagesc(image_asis); axis equal; axis tight; title('single cine "as is"'); colorbar; colormap('bone')
% figure; plot(1:512,image_asis(192,:),((1:384)+64),image_asis(:,256)); xlim([0 512]); title('"as is" profiles (a.u.)'); legend('cross-plane','in-plane','location','north');xlabel('pixels');
% % UNCOMMENT THIS IF YOU WANT TO SEE DIAGONAL PROFILES
% % x = [65 448]; y = [1 384]; [cx,cy,ProfDiagNeg]=improfile(image_asis,x,y);
% % x = [65 448]; y = [384 1]; [cx,cy,ProfDiagPos]=improfile(image_asis,x,y);
% % figure; plot(-14.16284:0.073916228:14.16284,ProfDiagNeg,-14.16284:0.073916228:14.16284,ProfDiagPos);
% % legend('- profile','+ profile','location','north'); title('"as is" diagonal profiles (a.u.)'); xlabel('Distance from isocenter (cm)');
% clear x y cx cy ProfDiagNeg_image_sum ProfDiagPos_image_sum 
% end

% SET THE ZERO
image_rescaled=-(image_asis-(2^14-1));
% figure; imagesc(image_rescaled); axis equal; axis tight; title('EPID image rescaled'); colorbar
% figure; plot(1:512,image_rescaled(192,:),'.-',((1:384)+64),image_rescaled(:,256),'.-'); xlim([0 512]); title('EPID image "re-zeroed" profiles'); legend('cross-plane','in-plane')

% REMOVE FLOOD FIELD CORRECTION FROM EACH EPID IMAGE TO OBTAIN "RAW" IMAGE
% (NOTE: DARK FIELD CORRECTION REMAINS)
image_rescaled_FFcorrOFF=(image_rescaled.*flood_00cm)/flood_00cm_mean;
% if n==start+round((stop-start)/2)
% figure; imagesc(image_rescaled_FFcorrOFF); axis equal; axis tight; title('Rescaled and FF correction removed'); colorbar
% figure; plot(1:512,image_rescaled_FFcorrOFF(192,:),'-',((1:384)+64),image_rescaled_FFcorrOFF(:,256),'-'); xlim([0 512]); title('Rescaled and FF correction removed'); legend('cross-plane','in-plane')
% end

% ADD A new FLOOD FIELD CORRECTION
% (NOTE: THIS flood_new IS ACQUIRED AT a certain DEPTH in SW)
image_rescaled_FFcorrOFF_FFNEWcorrON=(image_rescaled_FFcorrOFF./flood_new)*flood_new_mean;

image_sum = image_sum + image_rescaled_FFcorrOFF_FFNEWcorrON;
end

if size(image_sum,2)==1024
    image_sum=imresize(image_sum,0.50);
end

% PLOT FINAL IMAGE AND ITS PROFILES
% figure; imagesc(image_sum); axis equal; axis tight; title('Cine sum, rescaled, FF removed, new FF'); colorbar; colormap('bone')
% figure; plot(1:512,image_sum(192,:),((1:384)+64),image_sum(:,256)); xlim([0 512]); title('Pre-processed profiles (a.u.)'); legend('cross-plane','in-plane','location','South');xlabel('pixels'); 
% UNCOMMENT THIS IF YOU WANT TO SEE DIAGONAL PROFILES
% x = [65 448]; y = [1 384]; [cx,cy,ProfDiagNeg_image_sum]=improfile(image_sum,x,y);
% x = [65 448]; y = [384 1]; [cx,cy,ProfDiagPos_image_sum]=improfile(image_sum,x,y);
% figure; plot(-14.16284:0.073916228:14.16284,ProfDiagNeg_image_sum,-14.16284:0.073916228:14.16284,ProfDiagPos_image_sum);
% legend('- profile','+ profile','location','South'); title('Pre-processed diagonal profiles (a.u.)'); xlabel('Distance from isocenter (cm)');
clear x y cx cy ProfDiagNeg_image_sum ProfDiagPos_image_sum 
