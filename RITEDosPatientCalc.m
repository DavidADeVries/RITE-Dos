function [ DOSE_NOCORR, PatDoseConv,tps,HCM_map ] = RITEDosPatientCalc( WEDiso2epid, WEDsource2iso, EPID, tps)
   %UNTITLED2 Summary of this function goes here
    %   Detailed explanation goes here

    %% Prepare Patient EPIDs and TPS
try
    PatientEPIDdir = uigetdir();
    disp(PatientEPIDdir)
    EPID = EPIDprep(PatientEPIDdir);

    [TPS_dosemap_name, path] = uigetfile('*.dcm');
    TPS_dosemap_name = [path TPS_dosemap_name];
    tps=dicomread(TPS_dosemap_name); 
    tps_info=dicominfo(TPS_dosemap_name); 
    tps=double(tps);
%     nFractions=tps_info.FractionGroupSequence.Item_1.NumberOfFractionsPlanned;
%     nFractions = 23;
    nFractions = 1;
    tps=100*tps*tps_info.DoseGridScaling/nFractions;


    %% Adjusts the EPIDs for left-right and superior-inferior displacement.
    epid_elements=sort(EPID(:),'descend');
    epid_64_max=mean(epid_elements(101:151));
    epid_64_min=mean(epid_elements(end-150:end-100));
    mask=EPID>abs(epid_64_max+epid_64_min)/2;

    tps_64_max=sort(tps(:),'descend');
    tps_64_max=mean(tps_64_max(101:151));
    mask_tps=+(tps>abs(tps_64_max)*.5);

    mask_diff = double(mask)-double(mask_tps);
% 
%     epidsagSImagn=abs(sum(mask_diff(1:192,256))-sum(mask_diff(193:384,256)))/2;
%     epidsagSIsign=sign((sum(mask_diff(1:192,256))-sum(mask_diff(193:384,256))));
% 
%     epidsagLRmagn=abs(sum(mask_diff(192,1:256))-sum(mask_diff(192,257:512)))/2;
%     epidsagLRsign=sign((sum(mask_diff(192,1:256))-sum(mask_diff(192,257:512))));    
% 
%     EPID = circshift(EPID, [round(epidsagSIsign*epidsagSImagn) round(epidsagLRsign*epidsagLRmagn)]);   

    epid_mask=EPID>abs(epid_64_max+epid_64_min)/2;


    l_tps=sqrt(nnz(mask_tps)*0.05227*0.05227);
    l_epid=sqrt(nnz(epid_mask)*0.05227*0.05227);

    if abs(l_tps - l_epid) > 1
        disp('Field sizes of the treatment planning system and EPID images taken do not seem to match')
        disp('Results may be affected.')
    end
    
    % May also have an option to override when l's don't match.
    l=l_epid;




    %% Load commissioning data
    % Will include the F, f, and TPR arrays
    % and the w_s, l_s, d_s, and depths the data was taken at.
    % Gaussian weights
    load('CommissioningHCM300PM.mat');

    g1 = gauss_distribution(1:1000,500,1.7/.523);
    g2 = gauss_distribution(1:1000,500,1.7*2/.523);
    g3 = gauss_distribution(1:1000,500,1.7*10/.523);
    g4 = gauss_distribution(1:1000,500,1.7*30/.523);

    %% Get patient w, l, and d map from CT (DAVID)

    % Choose RT plan file
%     plan=dicominfo(planfile(1).name);
%     nFractions=plan.FractionGroupSequence.Item_1.NumberOfFractionsPlanned;
%     CTdir = uigetdir();
%     [WEDsource2iso, WEDiso2epid] = calculateWaterEquivalentDoseWithRayTrace(CTdir, 0);
%     WEDsource2iso = 10*ones(384,512)/100;
%     WEDiso2epid = 10*ones(384,512)/100;

    w_map=(WEDsource2iso+WEDiso2epid)*Constants.m_to_cm;
    
    d_map=(WEDiso2epid-WEDsource2iso)/2*Constants.m_to_cm;
    
    if size(w_map,1) > size(w_map,2)
        w_map = w_map';
        d_map = d_map';
    end
    
    % Keep this until you remake the WEDs
%     w_map = fliplr(w_map);
%     d_map = fliplr(d_map);
    %
%     w_map = circshift(w_map,-5,1);
%     d_map = circshift(d_map,-5,1);
    w = mean2(w_map(189:196,253:260));
    w = mean2(w_map(epid_mask));
    
    Fl_s = 5:5:20;
    Fw_s = 5:5:40;
    fl_s = Fl_s;
    fd_s = -10:5:10;
    TPRdepth = [0:0.5:20 21:30];
    TPRfields = 5:20;

    %% Construct F, f, and TPR maps from w, l, and d

    Fwindex = round((w_map-ones(384,512)*(Fw_s(1)))/0.1)+1;
    Flindex = round((l-Fl_s(1))/0.1)+1;
    
    outLow = Fwindex < 1;
    outHigh = Fwindex > size(FmatInt,1);
    Fwindex(outLow) = 1;
    Fwindex(outHigh) = size(FmatInt,1);
    
    if Flindex < 1
        Flindex = 1;
    elseif Flindex > size(FmatInt,2)
        Flindex = size(FmatInt,2);
    end
    
    
    fdindex = round((d_map-ones(384,512)*(fd_s(1)))/0.1)+1;
    flindex = round((l-fl_s(1))/0.1)+1;
    
    outLow = fdindex < 1;
    outHigh = fdindex > size(fmatInt,1);
    fdindex(outLow) = 1;
    fdindex(outHigh) = size(FmatInt,1);
    
    if flindex < 1
        flindex = 1;
    elseif flindex > size(FmatInt,2)
        flindex = size(FmatInt,2);
    end
    
    TPRlindex = round((l-TPRfields(1))/0.1)+1;
    TPRwindex = round((w_map./2-TPRdepth(1))/0.1)+1;
    TPRwdindex = round((w_map./2-d_map-TPRdepth(1))/0.1)+1;
    
    outLow = TPRlindex < 1;
    outHigh = TPRlindex > size(TPRmatInt,2);
    TPRlindex(outLow) = 1;
    TPRlindex(outHigh) = size(TPRmatInt,2);
    
    outLow = TPRwindex < 1;
    outHigh = TPRwindex > size(TPRmatInt,1);
    TPRwindex(outLow) = 1;
    TPRwindex(outHigh) = size(TPRmatInt,1);
    
    outLow = TPRwdindex < 1;
    outHigh = TPRwdindex > size(TPRmatInt,1);
    TPRwdindex(outLow) = 1;
    TPRwdindex(outHigh) = size(TPRmatInt,1);
    
    F_map = FmatInt(Fwindex,Flindex);
    F_map = reshape(F_map,384,512);

    f_map = fmatInt(fdindex,flindex);
    f_map = reshape(f_map,384,512);
    
    TPR1 = TPRmatInt(TPRwdindex,TPRlindex);
    TPR1 = reshape(TPR1, 384, 512);
    TPR2 = TPRmatInt(TPRwindex,TPRlindex);
    TPR2 = reshape(TPR2, 384, 512);

    TPRR_map = TPR1./TPR2;

    % Find map with w and l to weights.
    [ w_close, wwindex ] = min(abs(Fw_s - w));
    [ l_close, wlindex ] = min(abs(Fl_s - l));
    w_in = weights(:,(wwindex-1)*length(Fl_s)+wlindex,1);
    w_cr = weights(:,(wwindex-1)*length(Fl_s)+wlindex,2);
    HCM_map = HCM(:,:,(wwindex-1)*length(Fl_s)+wlindex);
    
    gsumcr=(w_cr(1)*g1+w_cr(2)*g2+w_cr(3)*g3+w_cr(4)*g4)/trapz(w_cr(1)*g1+w_cr(2)*g2+w_cr(3)*g3+w_cr(4)*g4);
    gsumin=(w_in(1)*g1+w_in(2)*g2+w_in(3)*g3+w_in(4)*g4)/trapz(w_in(1)*g1+w_in(2)*g2+w_in(3)*g3+w_in(4)*g4);

    %% Create Patient Dose maps
    % Before convolution
    DOSE_NOCORR=epid_mask.*EPID.*TPRR_map.*f_map./F_map;
    tpscax = mean2(tps(189:196,253:260));
    nocorrcax = (mean2(DOSE_NOCORR(189:196,253:260))-tpscax)./tpscax*100;
    %Convolving
    PatDoseConv = getDoseConv(EPID,epid_mask,gsumcr,gsumin,TPRR_map,F_map,f_map);
    convcax = (mean2(PatDoseConv(189:196,253:260))-tpscax)/tpscax*100;
    
    figure; imagesc((DOSE_NOCORR-tps)./tps*100); title(['% dose diff, NO CORR (CAX = ' num2str(nocorrcax) ')']);
    colorbar; set(gca, 'CLim', [-15 15]); colormap jet; axis equal; axis tight;
    figure; imagesc((PatDoseConv-tps)./tps*100); title(['% dose diff, CONV CORR (CAX = ' num2str(convcax) ')']);
    colorbar; set(gca, 'CLim', [-15 15]); colormap jet; axis equal; axis tight;
    
    convcax;


catch ME
    save 'PatCalcFail2'
    rethrow(ME)
end
end

