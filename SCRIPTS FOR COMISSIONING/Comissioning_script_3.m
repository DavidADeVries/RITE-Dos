% COMISSIONING SCRIPTS
close all
clear all
tic

working_dir='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\Pat00-U10'; %data directory
UnitStr='Unit10';
    %ResolutionStr='Half';
    ResolutionStr='Full';
EnergyStr='06X'; %'06X' or '15X' - MAKE SURE YOU ALSO SELECT CORRECT FLOOD FIELD!
MU=99; % DELIVERED BY THE BEAM YOU ARE ANALYZING
MU_tps=99;

% CHOOSE CORRECT FLOOD FIELDS
%-------------------------------------------------------------------------
% "FF_used" is the flood field image used to correct at moment of image acquisition. We want to remove this one
% "FF_new" is acquired seperately (before or after) through 20cm of water. We want to apply this one, to 'flatten' 
% the EPID response after 20cm, to make it correspond more closely to the flat dose at half depth (10cm).

%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20140818\MFF07645';%U9 06X empty beam HALF RES
%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150127\MFF13448.dcm';%U9 06X empty beam FULL RES
%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150512\MFF13580';%U9 06X empty beam FULL RES
%FF_new='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150219\MFF13464.dcm';%U9 06X, 20cm SW in beam
%FF_new='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150512\MFF13581';%U9 06X, 20cm SW in beam FULL RES

%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20140818\MFF07643';%U9 15X empty beam HALF RES
%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150127\MFF13453';%U9 15X empty beam FULL RES
%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150512\MFF13756';%U9 15X empty beam FULL RES
%FF_new='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150219\MFF13466';%U9 15X, 20cm SW in beam FULL RES
%FF_new='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150512\MFF13757';%U9 15X, 20cm SW in beam FULL RES


FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u10\20141103\MFF01955';%U10 06X empty beam
FF_new='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u10\20150312\MFF05104';%U10 06X 20cm SW in beam

%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u10\20141103\MFF01957';%U10 15X empty beam
%FF_new='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u10\20150312\MFF05105';%U10 06X 20cm SW in beam
%-------------------------------------------------------------------------




sets={
%FxStr   l   w     
{'01'}    5   5;
{'02'}    10  5;
{'03'}    15  5;
{'04'}    20  5;

{'05'}    5   10;
{'06'}    10  10;
{'07'}    15  10;
{'08'}    20  10;

 {'09'}   5   15;
 {'10'}   10  15;
{'11'}    15  15;
{'12'}    20  15;

{'13'}    5   20;
{'14'}    10  20;
{'15'}    15  20;
{'16'}    20  20;

{'17'}    5   25;
{'18'}    10  25;
{'19'}    15  25;
{'20'}    20  25;

{'21'}    5   30;
{'22'}    10  30;
{'23'}    15  30;
{'24'}    20  30;

{'25'}    5   35;
{'26'}    10  35;
{'27'}    15  35;
{'28'}    20  35;

{'29'}    5   40;
{'30'}    10  40;
{'31'}    15  40;
{'32'}    20  40;

};

tic
setup=0;
for i=1:size(sets,1)
    setup=setup+1;
sets(i,1)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
    Fractions=sets{i,1};
    l=cell2mat(sets(i,2));
    w=cell2mat(sets(i,3));
    
    RITE_Dos_Script_2

eval(['cd(''C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\RITE Dos 2015\',UnitStr,'\',ResolutionStr,'\Commissioning_results\',EnergyStr,'  '')']);

GoodnessMetric1=length(find(PercentDiffMatrix_Conv3>3))/length(find(mask>0))*100; % Percentage of in-field points with DD>3%
GoodnessMetric1str=num2str(GoodnessMetric1,3);
CAXpcdiffNoCorrStr=num2str(PercentDiffCAX_NoCorr,2);
CAXpcdiffConv3Str=num2str(PercentDiffCAX_Conv3,2);

ResultsMetrics(setup,1)=GoodnessMetric1; ResultsMetrics(setup,2)=PercentDiffCAX_NoCorr; ResultsMetrics(setup,3)=PercentDiffCAX_Conv3; ResultsMetrics(setup,4)=l;ResultsMetrics(setup,5)=w;

eval(['save Comm_res_l',l_string,'w',w_string,' DOSE_CONV DOSE_CONV_3 DOSE_EMPIRICAL DOSE_NOCORR eclipse epid PercentDiffMatrix_NoCorr PercentDiffMatrix_Empirical PercentDiffMatrix_Conv mask GoodnessMetric1;']);

h=figure;
%subtightplot(2,2,1); imagesc(PercentDiffMatrix_Empirical); title '% diff. (1)Empirical corr.(-10%,+10%)'
%axis equal; axis tight;  set(gca, 'CLim', [-10 10]);
subtightplot(1,3,1);plot(1:512,eclipse(192,:),1:512,DOSE_NOCORR(192,:),1:512,DOSE_CONV(192,:),1:512,DOSE_CONV_3(192,:),'k.');
legend('TPS','F(CAX) only','Conv, temp','Conv, final','location','South'); title('Cross-plane dose');xlim([1 512]);ylim([.85*DOSEmax DOSEmax]);%set(gca,'xtick',[])
ylabel('Dose (cGy)'); set(gca,'xticklabel',[]); grid

subtightplot(1,3,2); plot((1:384)+64,eclipse(:,256),(1:384)+64,DOSE_NOCORR(:,256),(1:384)+64,DOSE_CONV(:,256),(1:384)+64,DOSE_CONV_3(:,256),'k.');
legend('TPS','F(CAX) only','Conv, temp','Conv, final','location','South'); title('In-plane dose');xlim([1 512]);ylim([.85*DOSEmax DOSEmax]);%set(gca,'xtick',[])
set(gca,'xticklabel',[],'yticklabel',[]); grid

subtightplot(1,3,3); imagesc(PercentDiffMatrix_Conv3); title 'Dose, conv. corr. (-5%,+5%)';
axis equal; axis tight;  set(gca, 'CLim', [-5 5]); set(gca,'xticklabel',[],'yticklabel',[])
eval(['xlabel({''Tot infield pts w/ DD>3% is ',GoodnessMetric1str,'%'';''F(CAX) only (no off-axis corr): ',CAXpcdiffNoCorrStr,'% off @ CAX'';''Gaussian convolution corr: ',CAXpcdiffConv3Str,'% off @ CAX''})']);

set(h,'position',[0 100 1280 450])

set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0 0 28 13]); %x_width=10cm y_width=15cm

eval(['saveas(h,''maps_l',l_string,'w',w_string,' '',''jpg'')']);
cd(working_dir);

end
eval(['cd(''C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\RITE Dos 2015\',UnitStr,'\',ResolutionStr,'\Commissioning_results\',EnergyStr,'  '')']);
save Results_summary ResultsMetrics
toc
 
