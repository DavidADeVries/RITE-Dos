set(0,'DefaultFigureWindowStyle','normal');
%clear all
clearvars -except CTdata
close all; clc
%load CTdata.mat; 
% figure; imagesc(CTdata(:,:,1)); title('Slice 1')
% figure; imagesc(CTdata(:,:,50)); title('Slice 50')
% figure; imagesc(CTdata(:,:,size(CTdata,3)-50)); title('Slice Max-50')
% figure; imagesc(CTdata(:,:,size(CTdata,3))); title('Slice Max')

epidcols=256%1:512;
epidrows=192%1:384;

shouldIsave=false

for ImAng=0:90:270 
%ImAng=0;
ImAng
% 1. Read useful data from the DICOM headers of the CT slices (CT... .dcm) 
% and the plan file (RP... .dcm).
CTfilenames=dir('CT*.dcm');  %Make List of "CT" filenames in folder
nCTfiles=length(CTfilenames); %Number of dicom files in folder
for i=1:nCTfiles
    currentfilename=CTfilenames(i).name; 
    CTdicoms{i}=dicomread(currentfilename);
    CTdicoms_info{i}=dicominfo(currentfilename); 
    %CTdicoms_SliceLocation{i}=CTdicoms_info{i}.SliceLocation; %
end 
clear i currentfilename CTfilenames
PLANfilename=dir('RP*.dcm');
PLANdicom=dicomread(PLANfilename(1).name);
PLANdicom_info=dicominfo(PLANfilename(1).name); 
clear PLANfilename

%---------------------------------------------------------------------------
%---------------------------------------------------------------------------
% I. GEOMETRY OF THE IRRADIATION AND EPID IMAGING
%This 3x3 matrix will be useful to rotate the EPID pixel coordinate by ImAng 
InverseRotFrame=[cosd(ImAng),-sind(ImAng),0;sind(ImAng),cosd(ImAng),0;0,0,1];
SrDist=-100; %Source distance --> -100 is 100cm above isocentre. This quantity generally does not change.
DetDist=50; %Detector distance (EPID) -- > 50 is 50cm below isocentre. This should change only if you move the EPID.
SrPosRoom = SrDist*[-sind(ImAng);cosd(ImAng);0]; % This is the location of the source in the "room" frame of reference
% so if gantry=0, SrPosRoom=[0,-100,0]. But
% if gantry is 90, SrPosRoom=[+100,0,0]. 
% So, the Room Cord System has origin at iso and coordinates [X Y Z] where
% +X towards Gantry right (L hand of patient if patient supine)
% +Y towards floor
% +Z towards sup (head)
%---------------------------------------------------------------------------
% I.b EPID details
cpp=512; % "cross-plane pixels", 512 on the varian aS500 and aS1000 at half res.
ipp=384; % "in-plane pixels", 384 on the Varian aS500 and aS1000 at half res.
cpcm=40.140795; % "cross-plane cm", the dimensions of the detector plane.
ipcm=30.1056; % "in-plane cm", the dimensions of the detector plane.

% This following variable will be useful for future gamma analyses
% units=mm/pixel
PixelSizePhysical=(10*cpcm/cpp);

% II. ACQUISITION PARAMETERS OF YOUR CT DATASET

% II.b. CT DATA ACQUISITION PARAMETERS 
rows=CTdicoms_info{1}.Height; %n. of pixels in CT scan (dicom header: 0028,0010  Rows: 512)
cols=CTdicoms_info{1}.Width; %n. of pixels in CT scan (dicom header: 0028,0011  Columns: 512)
width=CTdicoms_info{1}.ReconstructionDiameter/10;%cm
height=CTdicoms_info{1}.ReconstructionDiameter/10;%cm
thick=CTdicoms_info{1}.SliceThickness/10; %cm  
slices=nCTfiles; %number of slices
station=CTdicoms_info{1}.StationName %HOST-7103=Sim2 ; HOST-7745=Sim3

% II.c CT SCANNER CALIBRATION
load('C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\RITE Dos 2015\CT_scanner_data\CT2013.mat') % this is the CT machine calibration, i.e. the HU to electron density correspondance (CTcalib)
CTinterp1(:,1)=-14999:15000; % these 4 lines interpolate the CT machine calibration
CTinterp2(:,1)=interp1(CTcalib(:,1),CTcalib(:,2),CTinterp1(:,1),'linear','extrap');

% IV. OTHER PARAMETERS
NumPnt=333
%round(100/thick)+1; % MAKE SURE IT IS AN ODD NUMBER % whyyy??
% this is the number of points in which the source-to-detector rayline is broken into.
% at every point, the electron density is estimated from the CT number.
% The patient is in the 100cm range between 50cm and 150cm away from the source. 
% So if the CT has 2mm slices, this corresponds to 500 slices. 
% In conclusion, having NumPnt>500 would not improve results but would
% require more computational time. 
% IN THE SAME WAY, IF SLICES ARE 3MM APART, 100cm/.3=333 points
% -----------------------------------------------------------------------
% THIS IS ACTUALLY STUPID! THICK IS IN THE OPPOSITE DIRECTION!

wed_iso_to_EPID=zeros(512,384);
wed_source_to_iso=zeros(512,384);
wed_total=zeros(512,384);

% ECLIPSE FRAME [X,Y,Z]
% +X towards Gantry right (L hand of patient if patient supine)
% +Y towards floor
% +Z towards sup (head)
% MATLAB FRAME [row,col,slice] (that of CTdata)
% +row towards floor = Y
% +col towards Gantry right (R hand of patient if patient prone) = X 
% +slice towards sup (head) = Z

% NOTE: THE TWO ORIGINS DO NOT COINCIDE. The Origin of the TPS frame is in
% the "DICOM ORIGIN" decided at time of CT. For the origin of the
% Matlab/CTdata frame, consider that pixel (1,1,1)is found in the upper
% left corner: ABOVE(ANT if supine), Gantry LEFT (Pat R if supine), 
% and INF(feet) of the patient

% All the vectors below ("vector_...") are in cm and
% in the MATLAB/CTdata frame of reference

% --------- UPDATED % VECTOR: FROM DICOM ORIGIN TO BEAM ISO 
vector_DcmOrig2Iso(1)=-PLANdicom_info.BeamSequence.Item_1.ControlPointSequence.Item_1.IsocenterPosition(2)/10; %this minus sign has to be there for pat c259112, sim2, prone
vector_DcmOrig2Iso(2)=-PLANdicom_info.BeamSequence.Item_1.ControlPointSequence.Item_1.IsocenterPosition(1)/10; %this minus sign has to be there for pat01, pat03 sim2, prone
vector_DcmOrig2Iso(3)=PLANdicom_info.BeamSequence.Item_1.ControlPointSequence.Item_1.IsocenterPosition(3)/10;
vector_DcmOrig2Iso

% --------- UPDATED % VECTOR: FROM DICOM ORIGIN TO CTdata's (1,1,1) %SIM3
vector_DcmOrig2CTcorner(1)=-CTdicoms_info{nCTfiles}.ImagePositionPatient(2)/10; %this minus sign has to be there for pat c259112, sim2, prone
vector_DcmOrig2CTcorner(2)=-CTdicoms_info{nCTfiles}.ImagePositionPatient(1)/10;
vector_DcmOrig2CTcorner(3)=CTdicoms_info{nCTfiles}.ImagePositionPatient(3)/10;
vector_DcmOrig2CTcorner

% VECTOR: FROM CTdata's (1,1,1)) TO DICOM ORIGIN 
vector_CTcorner2DcmOrig=-vector_DcmOrig2CTcorner

% VECTOR: FROM CTdata's (1,1,1)) TO BEAM ISO 
vector_CTcorner2Iso=vector_CTcorner2DcmOrig+vector_DcmOrig2Iso
vector_CTcorner2Iso=transpose(vector_CTcorner2Iso)




tic
% THE FOLLOWING EXPRESSIONS ARE IN THE TPS FRAME OF REF, WITH ORIGIN AT ISO
for i = epidcols%cpp/2%:cpp; %Range of cross-plane pixels in EPID to use
 i
    for j = epidrows%ipp/2%:ipp %Range of in-plane pixels in EPID to use

        icm=(i-(cpp+1)/2)*cpcm/cpp;%converting to isocentre coordinate frame
        jcm=(j-(ipp+1)/2)*ipcm/ipp;%and converting from pixels to cm
        
        PixCoord=[icm; DetDist; -jcm]; %w/r to isocenter
        PixCoord=InverseRotFrame*PixCoord;
        
        P1=SrPosRoom+(PixCoord-SrPosRoom)/3; 
        P2=PixCoord;
       
        LP=[];
        for n = 1:NumPnt
            vector_Iso2Point_TPS=P1+(P2-P1)*(n-1)/(NumPnt-1);%(cm) takes you from Beam ISO to point on the rayline IN TPS FRAME
            
            % LETS CHANGE THIS VECTOR TO THE MATLAB FRAME
            vector_Iso2Point=[vector_Iso2Point_TPS(2); vector_Iso2Point_TPS(1); vector_Iso2Point_TPS(3)];

            % VECTOR: FROM CTdata's (1,1,1) TO POINT ON RAYLINE 
            vector_CTcorner2Point=vector_CTcorner2Iso+vector_Iso2Point;
            V=vector_CTcorner2Point; % for short
            
            % I need the coordinate of this point w/r to CTdata
          
            V_ML=[V(1)*rows/height V(2)*cols/width V(3)/thick];
            
            % Now let's find CT HU numbers for each point along the rayline
            
            try %this catches the error when our point is outside the ct dataset and assigns value -1000
                CTVal=CTdata(round(V_ML(1)), round(V_ML(2)), round(V_ML(3))) - 1024;
            catch
                CTVal=-1000;
            end

            Point = sqrt((vector_Iso2Point_TPS(1)-SrPosRoom(1))^2+(vector_Iso2Point_TPS(2)-SrPosRoom(2))^2+(vector_Iso2Point_TPS(3)-SrPosRoom(3))^2);
            LP=[LP;Point CTVal]; % this is a concatenation
        end
            
 %0.063sec
        % Now we convert CT number profile to electron density profile.
        % To clarify, LP is in HUs, while density is in electron density units
   
        density=zeros(NumPnt,2);
        density(:,1)=LP(:,1);
        for k = 1:NumPnt
            density(k,2)=CTinterp2(CTinterp1==LP(k,2));
        end
%0.072sec     
        %calculate WEDs from profile
       
        % Now I want to find the point on the "density" vector which is on
        % (or as close as possible) to the isocenter plane. Because I
        % divided the line which is 50cm above and 50cm below the iso plane
        % into NumPnt pieces, the middle point is NumPnt/2+0.5
        array_position=NumPnt/2+0.5;
        %[min_difference, array_position] = min(abs(density(:,1)-100));
        %array pos is: "which data point is closest to 0"
        %min diff is: "how close it is"
        wed_source_to_iso(i,j)=trapz(density(1:array_position,1),density(1:array_position,2));
        wed_iso_to_EPID(i,j) = trapz(density(array_position:NumPnt,1),density(array_position:NumPnt,2));
        wed_total=wed_source_to_iso+wed_iso_to_EPID;
%0.01sec
if i==256 & j==192
    figure; plot(LP(:,1),LP(:,2),'-bx'); grid on; title('density'); %axis([90 120 0 2])
end
    
    end %closes the j loop
end %closes the i loop

clear C CTVal P1 P2 PixCoord3D PixCoord3DRoom PixelSizeAtIso PixelSizePhysical Point n
toc;
%profile viewer
% clear variables from the inner (n) loop
% clear C CTVal E L P1 P2 PixCoord2D PixCoord3D PixCoord3DRoom Point n
% 
% 
% 
% % clear variables from the (i,j) loop
clear i j icm jcm k min_difference array_position
clear ImCoord ImRoomCoord ImRotCoord InverseRotFrame
%clear DetDist SrDist SrPosRoom
clear CTinterp1 CTinterp2
clear full_density 
clear CTcalib 
%clear CTdata
clear lengthLP
%clear LP 
% 
% % clear parameters
clear NumPnt 
clear cpcm cpp ipcm ipp
clear cols height iso rows slices thick width

wed_source_to_iso_TRANSP=transpose(wed_source_to_iso);
wed_iso_to_EPID_TRANSP=transpose(wed_iso_to_EPID);
wed_total_TRANSP=transpose(wed_total);
clear wed_iso_to_EPID wed_source_to_iso wed_total

% BUT THERE IS A SUP-INF FLIP, SO LET'S DO IT NOW:
wed_source_to_iso_TRANSP=flipud(wed_source_to_iso_TRANSP);
wed_iso_to_EPID_TRANSP=flipud(wed_iso_to_EPID_TRANSP);
wed_total_TRANSP=flipud(wed_total_TRANSP);

sum(wed_source_to_iso_TRANSP(wed_source_to_iso_TRANSP~=0))/nnz(wed_source_to_iso_TRANSP~=0)
sum(wed_iso_to_EPID_TRANSP(wed_iso_to_EPID_TRANSP~=0))/nnz(wed_iso_to_EPID_TRANSP~=0)
sum(wed_total_TRANSP(wed_total_TRANSP~=0))/nnz(wed_total_TRANSP~=0)

% -----------------------------------------------------------------------
%Save the 3 WED matrices
if shouldIsave
if ImAng==0
    save('WED-GA000.mat','wed_iso_to_EPID_TRANSP','wed_source_to_iso_TRANSP','wed_total_TRANSP');
elseif ImAng==90
    save('WED-GA090.mat','wed_iso_to_EPID_TRANSP','wed_source_to_iso_TRANSP','wed_total_TRANSP');
elseif ImAng==180
    save('WED-GA180.mat','wed_iso_to_EPID_TRANSP','wed_source_to_iso_TRANSP','wed_total_TRANSP');
elseif ImAng==270
    save('WED-GA270.mat','wed_iso_to_EPID_TRANSP','wed_source_to_iso_TRANSP','wed_total_TRANSP');
end
end
% -----------------------------------------------------------------------

% Plot the 3 WED matrices
% subplot(3,1,1);
% imagesc(wed_source_to_iso_TRANSP); title 'source-to-isoplane WED'; colorbar; axis equal; axis([0 512 0 384]);
% subplot(3,1,2);
% imagesc(wed_iso_to_EPID_TRANSP); title 'isoplane-to-EPID WED'; colorbar; axis equal; axis([0 512 0 384]);
% subplot(3,1,3);
% imagesc(wed_total_TRANSP); title 'total WED (cm)'; colorbar; axis equal; axis([0 512 0 384]);
% [ax,h3]=suplabel('WEDs: SWP 22cm CTd on May 27 2013' ,'t'); % CHANGE THIS TITLE TO MATCH CORRECT DATA
% set(h3,'FontSize',10)
% clear ax h3


% THE PLOT BELOW IS USEFUL TO VERIFY THAT YOU 
% ASSIGNED CORRECT COORDINATES TO iso IN LineProfileSP1.m
% 
% figure
% plot(LP(:,1),LP(:,2),'-bx');
% grid on
% %axis([90 120 0 2])
% title('density')


% 

% figure; imagesc(wed_source_to_iso_TRANSP); colorbar; axis equal; axis tight; title('WED, source to isoplane')
% figure; imagesc(wed_iso_to_EPID_TRANSP); colorbar;  axis equal; axis tight; title('WED, isoplane to EPID')
% figure; imagesc(wed_total_TRANSP); colorbar;  axis equal; axis tight; title('WED, total')
% figure; plot(1:512,wed_source_to_iso_TRANSP(192,:),1:512,wed_iso_to_EPID_TRANSP(192,:),1:512,wed_total_TRANSP(192,:)); 
% legend('source to isoplane','isoplane to EPID','total'); title('WED crossplane profiles')
% figure; plot(1:384,wed_source_to_iso_TRANSP(:,256),'-',1:384,wed_iso_to_EPID_TRANSP(:,256),'--',1:384,wed_total_TRANSP(:,256)); 
% legend('source to isoplane','isoplane to EPID','total'); title('WED inplane profiles')

end
