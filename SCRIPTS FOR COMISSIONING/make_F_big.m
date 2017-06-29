% THIS SCRIPT TAKES DICOM IMAGES AS EXPORTED FROM THE ECLIPSE TPS AND MAKES A
% MATRIX OF DOSE AT CAX (D_matrix) FOR DIFFERENT FIELD SIZES (l, cm) AND DEPTHS 
% IN WATER (phantom thickness w, cm).
close all; clear all
addpath(genpath(pwd));

% 1. parameters involved in making the array of D values (from TPS)
%-------------------------------------------------------------------------
currDir = pwd;
TPSdoseDir=[currDir '\Comissioning data\TPS phantom mid-depth dose (F)'];
% Dose is measured in the midpoint of the phantom. 
l_TPS=5:5:20;
depth_TPS=[2.8 5.3 7.8 10.3 12.8 15.3 17.8]; % 06X U10 only
MU_TPS=99;
%-------------------------------------------------------------------------

% 2. parameters involved in making the array of S values (from EPID)
%-------------------------------------------------------------------------
EPIDsignalDir=[currDir '\Comissioning data\EPID images with centered phantoms (F)'];
l_epids=[5 10 15 20];
%w_SW=[5 10 15 20 25 30 35 40]; % will make 32 fractiona
w_SW=[5 10 15 20 25 30 35]; % will make 28
MU_epid=99; % may be diff for Unit, Energy, Resolution
UnitStr='Unit09';
ResolutionStr='Half';




%-------------------------------------------------------------------------


% 3. parameters involved in both D(TPS) and S(EPID)
%-------------------------------------------------------------------------
DoSave=true;
FrameLossCorrection=true;
EnergyStr='06X';
pix=8; % width of square (in number of pixels) around the CAX to be averaged 
CAXrows=(384/2-pix/2+1):(384/2+pix/2);
CAXcols=(512/2-pix/2+1):(512/2+pix/2);
w_interp=5:0.1:45;
l_interp=5:0.5:20;
%-------------------------------------------------------------------------


% 1. Make an array of D values from TPS dose maps
%-------------------------------------------------------------------------
w_TPS=depth_TPS*2;
nFractions=1;

cd(TPSdoseDir)

dirs=dir('w*.dcm');
for i=1:size(dirs,1)
    TPSmap=dicomread(dirs(i).name);
    TPSinfo=dicominfo(dirs(i).name);
    TPSmap=double(TPSmap);
    TPSmap=100*TPSmap*TPSinfo.DoseGridScaling/nFractions;
    TPSdose(i)=mean(mean(TPSmap(CAXrows,CAXcols)));
end
TPSdose=transpose(TPSdose)/MU_TPS;
% If the appropriate notation was followed, TPSdose starts from thinnest
% phantom, and its four increasing field sizes. Then the thicker phantom,
% etc.
D_TPS=reshape(TPSdose,size(l_TPS,2),size(w_TPS,2))';

%PLOT D_TPS MATRIX - verify it looks sensible
figure; surfc(l_TPS,w_TPS,D_TPS); xlabel('square field size (cm)'); ylabel('phantom thickness (cm)'); title('D from TPS 8x8 pixels on CAX')

%EXTRAPOLATE TO THICKER WATER, 45cm total thickness
D_TPS_extrap=D_TPS;
for col=1:4
    D_TPS_extrap(size(D_TPS,1)+1,col)=interp1(w_TPS,D_TPS(:,col),45,'linear','extrap');
end

%PLOT D_TPS_extrap MATRIX - verify it looks sensible
figure; surfc(l_TPS,[w_TPS 45],D_TPS_extrap); xlabel('square field size (cm)'); ylabel('phantom thickness (cm)'); title('D from TPS 8x8 pixels on CAX')

% INTERPOLATE. now, let's interpolate D_matrix_extrap

D_TPS_extrap_interp=interp2(transpose(l_TPS),[w_TPS 45],D_TPS_extrap,transpose(l_interp),w_interp,'linear');

D_matrix_interp_with_headings=zeros(length(w_interp)+1,length(l_interp)+1);
D_matrix_interp_with_headings(2:size(D_TPS_extrap_interp,1)+1,2:size(D_TPS_extrap_interp,2)+1)=D_TPS_extrap_interp;
D_matrix_interp_with_headings(2:size(D_TPS_extrap_interp,1)+1,1)=w_interp;
D_matrix_interp_with_headings(1,2:size(D_TPS_extrap_interp,2)+1)=l_interp;

%PLOT D MATRIX - verify it looks sensible
figure; surfc(l_interp,w_interp,D_TPS_extrap_interp)
xlabel('square field size (cm)')
ylabel('phantom thickness (cm)')
title('D from TPS 8x8 pixels on CAX')



% 2. Make an array of S values
%-------------------------------------------------------------------------
w_couch=0.6; % estimate of the water equivalent thickness of the couch
w_epids=w_SW+w_couch;

cd(EPIDsignalDir);

% ------------------------------------------------------------------------------------
if FrameLossCorrection
% Now I'll correct for the fact that I may have dropped some end-beam frames
if strcmp(UnitStr,'Unit09')
    if strcmp(EnergyStr,'06X')
        if strcmp(ResolutionStr,'Half')
            numImagesCorr=0.1616*MU_epid+0.2133; % data from June 29
        elseif strcmp(ResolutionStr,'Full')
            numImagesCorr=0.0941*MU_epid+0.55185; %data from May 12 2015, S.P.
        end
    elseif strcmp(EnergyStr,'15X')
        if strcmp(ResolutionStr,'Half')
            numImagesCorr=0.3725*MU_epid-0.68475; %data from May 27 2015, S.P.
        elseif strcmp(ResolutionStr,'Full')
            numImagesCorr=0.1937*MU_epid+0.08325; %data from May 12 2015, S.P.
        end
    end
elseif strcmp(UnitStr,'Unit10')
    if strcmp(EnergyStr,'06X')
        numImagesCorr=0.093*MU_epid+0.5581; %data from March 12 2015, S.P.
    elseif strcmp(EnergyStr,'15X')
        numImagesCorr=0.0982*MU_epid+0.3301; %data from Sept 22 2015, S.P.
    end
end
numImagesCorr;
end


dirs={
'w05l05' 'w05l10' 'w05l15' 'w05l20' 'w10l05' 'w10l10' 'w10l15' 'w10l20' 'w15l05' 'w15l10' ...
'w15l15' 'w15l20' 'w20l05' 'w20l10' 'w20l15' 'w20l20' 'w25l05' 'w25l10' 'w25l15' ...
'w25l20' 'w30l05' 'w30l10' 'w30l15' 'w30l20' 'w35l05' 'w35l10' 'w35l15' 'w35l20'
};
for i=1:size(dirs,2)
    [EPIDimage,nCINEfiles(i)]=EPID_prepare_4(cell2mat(dirs(i)));
    EPIDimageCAX=mean(mean(EPIDimage(CAXrows,CAXcols)));
    Svalues(i)=EPIDimageCAX;
    if FrameLossCorrection
          Svalues(i)=Svalues(i)*numImagesCorr/nCINEfiles(i); 
    end
    
end
Svalues=transpose(Svalues);



% IMPORTANT - Now I'm assuming that numeric order of EPID images corresponds to first
% increasing through all the field size values (e.g. 5, 10, 15, 20) and then
% switching to the thicker solid water (e.g. 5, 10, 15, 20, 25, 30, 35).
S_matrix=reshape(Svalues,size(l_epids,2),size(w_epids,2))/MU_epid; S_matrix=transpose(S_matrix);

%PLOT S MATRIX - verify it looks sensible
figure; surfc(l_epids,w_epids,S_matrix)
xlabel('square field size (cm)')
ylabel('phantom thickness (cm)')
title('S from EPID 8x8 pixels on CAX')

% Now I need to extrapolate values of S at deeper depths, because I didn't go
% far enough.
for i=1:size(l_epids,2)
    S_matrix_extrap(:,i)=interp1(w_epids,S_matrix(:,i),[w_epids 40 45],'linear','extrap');
end

%PLOT S MATRIX - verify it looks sensible
figure; surfc(l_epids,[w_epids 40 45],S_matrix_extrap)
xlabel('square field size (cm)')
ylabel('phantom thickness (cm)')
title('S from EPID 8x8 pixels on CAX')

% Now, let's interpolate the S matrix so that:
% Rows are total water depth crossed as in w_interp, defined above
% Columns are equivalent square fields as in l_interp, defined above

S_matrix_extrap_interp=interp2(transpose(l_epids),[w_epids 40 45],S_matrix_extrap,transpose(l_interp),w_interp,'spline');
S_matrix_interp_with_headings=zeros(length(w_interp)+1,length(l_interp)+1);
S_matrix_interp_with_headings(2:size(S_matrix_extrap_interp,1)+1,2:size(S_matrix_extrap_interp,2)+1)=S_matrix_extrap_interp;
S_matrix_interp_with_headings(2:size(S_matrix_extrap_interp,1)+1,1)=w_interp;
S_matrix_interp_with_headings(1,2:size(S_matrix_extrap_interp,2)+1)=l_interp;

%PLOT S MATRIX - verify it looks sensible
figure; surfc(l_interp,w_interp,S_matrix_extrap_interp)
xlabel('square field size (cm)')
ylabel('phantom thickness (cm)')
title('S from TPS 8x8 pixels on CAX')


% 3. Make an array of F=S/D values
%-------------------------------------------------------------------------
F_matrix=S_matrix_extrap_interp./D_TPS_extrap_interp;
F_matrix_interp_with_headings=zeros(length(w_interp)+1,length(l_interp)+1);
F_matrix_interp_with_headings(2:size(F_matrix,1)+1,2:size(F_matrix,2)+1)=F_matrix;
F_matrix_interp_with_headings(2:size(F_matrix,1)+1,1)=w_interp;
F_matrix_interp_with_headings(1,2:size(F_matrix,2)+1)=l_interp;

%PLOT F MATRIX
figure; surfc(l_interp,w_interp,F_matrix)
xlabel('square field size (cm)')
ylabel('phantom thickness (cm)')
title('F on CAX')

cd ..\..

if DoSave
    cd 'Comissioning data'
        eval(['save F_matrix_interp_with_headings_',UnitStr,'_',EnergyStr,' F_matrix_interp_with_headings']);
    cd ..
end

% %figure; 
% plot(l,D_matrix(1,:),'.--',l,D_matrix(2,:),'.--',l,D_matrix(3,:),'.--',l,D_matrix(4,:),'.--',l,D_matrix(5,:),'.--',...
%     l,D_matrix(6,:),'.--',l,D_matrix(7,:),'.--',l,D_matrix(8,:),'.--')
% title('D(CAX) (Central 8x8 pixels, 6MV, U9)')
% xlabel('l(cm)')
% ylabel('D (cGy)')
% box on
% legend('w=3.1','w=5.6','w=10.6','w=15.6','w=20.6','w=25.6','w=30.6','w=35.6')
% 
% %figure; 
% plot(w,D_matrix(:,1),'.--',w,D_matrix(:,2),'.--',w,D_matrix(:,3),'.--',w,D_matrix(:,4),'.--',w,D_matrix(:,5),'.--',...
%     w,D_matrix(:,6),'.--',w,D_matrix(:,7),'.--',w,D_matrix(:,8),'.--')
% title('D(CAX) (Central 8x8 pixels, 6MV, U9)')
% xlabel('w(cm)')
% ylabel('D (cGy)')
% box on
% legend('l=2.5cm','l=5cm','l=7.5cm','l=10cm','l=12.5cm','l=15cm','l=17.5cm','l=20cm')


