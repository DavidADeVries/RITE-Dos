clear all
tic

% using curve w12fs05

load('DOSE_FcorrDerek_masked_w06fs05_usingFw12fs05_Fw12fs15.mat')
gamma_w06l05_usingFw12fs05=GammaMap(eclipse_masked,...
    DOSE_FcorrDerek_masked_Fw12fs05,3,0.03);

load('DOSE_FcorrDerek_masked_w06fs10_usingFw12fs05_Fw12fs15.mat')
gamma_w06l10_usingFw12fs05=GammaMap(eclipse_masked,...
    DOSE_FcorrDerek_masked_Fw12fs05,3,0.03);

load('DOSE_FcorrDerek_masked_w06fs15_usingFw12fs05_Fw12fs15.mat')
gamma_w06l15_usingFw12fs05=GammaMap(eclipse_masked,...
    DOSE_FcorrDerek_masked_Fw12fs05,3,0.03);

load('DOSE_FcorrDerek_masked_w26fs05_usingFw12fs05_Fw12fs15.mat')
gamma_w26l05_usingFw12fs05=GammaMap(eclipse_masked,...
    DOSE_FcorrDerek_masked_Fw12fs05,3,0.03);

load('DOSE_FcorrDerek_masked_w26fs10_usingFw12fs05_Fw12fs15.mat')
gamma_w26l10_usingFw12fs05=GammaMap(eclipse_masked,...
    DOSE_FcorrDerek_masked_Fw12fs05,3,0.03);


save('gamma_results_Fw12fs05','gamma_w06l05_usingFw12fs05',...
    'gamma_w06l10_usingFw12fs05','gamma_w06l15_usingFw12fs05',...
    'gamma_w26l05_usingFw12fs05','gamma_w26l10_usingFw12fs05');


clear all
close all

% using curve w12fs15

load('DOSE_FcorrDerek_masked_w06fs05_usingFw12fs05_Fw12fs15.mat')
gamma_w06l05_usingFw12fs15=GammaMap(eclipse_masked,...
    DOSE_FcorrDerek_masked_Fw12fs15,3,0.03);

load('DOSE_FcorrDerek_masked_w06fs10_usingFw12fs05_Fw12fs15.mat')
gamma_w06l10_usingFw12fs15=GammaMap(eclipse_masked,...
    DOSE_FcorrDerek_masked_Fw12fs15,3,0.03);

load('DOSE_FcorrDerek_masked_w06fs15_usingFw12fs05_Fw12fs15.mat')
gamma_w06l15_usingFw12fs15=GammaMap(eclipse_masked,...
    DOSE_FcorrDerek_masked_Fw12fs15,3,0.03);

load('DOSE_FcorrDerek_masked_w26fs05_usingFw12fs05_Fw12fs15.mat')
gamma_w26l05_usingFw12fs15=GammaMap(eclipse_masked,...
    DOSE_FcorrDerek_masked_Fw12fs15,3,0.03);

load('DOSE_FcorrDerek_masked_w26fs10_usingFw12fs05_Fw12fs15.mat')
gamma_w26l10_usingFw12fs15=GammaMap(eclipse_masked,...
    DOSE_FcorrDerek_masked_Fw12fs15,3,0.03);

toc

save('gamma_results_Fw12fs15','gamma_w06l05_usingFw12fs15',...
    'gamma_w06l10_usingFw12fs15','gamma_w06l15_usingFw12fs15',...
    'gamma_w26l05_usingFw12fs15','gamma_w26l10_usingFw12fs15');




gamma_WB270_usingFw12fs05=GammaMap(eclipse_masked,...
    DOSE_FcorrDerek_masked_w12fs05,3,0.03);
gamma_WB270_usingFw12fs10=GammaMap(eclipse_masked,...
    DOSE_FcorrDerek_masked_w12fs10,3,0.03);
gamma_WB270_usingFw12fs15=GammaMap(eclipse_masked,...
    DOSE_FcorrDerek_masked_w12fs15,3,0.03);


clear all
tic
load('WS12_w16fs05_DalsCT_Fcorr-Derek.mat')
gamma_w16l05_usingFw12fs05=GammaMap(eclipse_masked,...
    DOSE_FcorrDerek_masked_w12fs05,3,0.03);
load('WS13_w16fs10_DalsCT_Fcorr-Derek.mat')
gamma_w16l10_usingFw12fs10=GammaMap(eclipse_masked,...
    DOSE_FcorrDerek_masked_w12fs10,3,0.03);
load('WS14_w16fs15_DalsCT_Fcorr-Derek.mat')
gamma_w16l15_usingFw12fs15=GammaMap(eclipse_masked,...
    DOSE_FcorrDerek_masked_w12fs15,3,0.03);
save('gamma_results_SWPw16_samefsFcorr','gamma_w16l05_usingFw12fs05',...
    'gamma_w16l10_usingFw12fs10','gamma_w16l15_usingFw12fs15')
toc



gamma_LT0_divBy1p0679_usingFw12fs05=GammaMap(eclipse_masked,DOSE_FcorrDerek_masked_w12fs05_divBy1p0679,3,0.03);
gamma_LT0_divBy1p0679_usingFw12fs10=GammaMap(eclipse_masked,DOSE_FcorrDerek_masked_w12fs10_divBy1p0679,3,0.03);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Aug 7 2013 - 3%3mm - On EPID images

tic;

load('images00958_00982.mat');
load('images00983_01006.mat');
gamma_WB90_normVSnorm=GammaMap(images00958_00982,images00983_01006,3,.03);
clear images00958_00982 images00983_01006

%load a normal image
load('images01007_01032.mat');

%compare it against these 1mm closings of leaf
%bank 30
load('images01033_01057.mat');
gamma_WB90_normVS_LeafClosure_01mm_3mm3pc=GammaMap(images01007_01032,images01033_01057,3,.03);
clear images01033_01057

load('images01058_01082.mat');
gamma_WB90_normVS_LeafClosure_02mm_3mm3pc=GammaMap(images01007_01032,images01058_01082,3,.03);
clear images01058_01082

load('images01083_01107.mat');
gamma_WB90_normVS_LeafClosure_03mm_3mm3pc=GammaMap(images01007_01032,images01083_01107,3,.03);
clear images01083_01107

load('images01108_01132.mat');
gamma_WB90_normVS_LeafClosure_04mm_3mm3pc=GammaMap(images01007_01032,images01108_01132,3,.03);
clear images01108_01132

load('images01133_01157.mat');
gamma_WB90_normVS_LeafClosure_05mm=GammaMap(images01007_01032,images01133_01157,3,.03);
clear images01133_01157

load('images01158_01182.mat');
gamma_WB90_normVS_LeafClosure_06mm=GammaMap(images01007_01032,images01158_01182,3,.03);
clear images01158_01182

load('images01183_01207.mat');
gamma_WB90_normVS_LeafClosure_07mm=GammaMap(images01007_01032,images01183_01207,3,.03);
clear images01183_01207

load('images01208_01232.mat');
gamma_WB90_normVS_LeafClosure_08mm=GammaMap(images01007_01032,images01208_01232,3,.03);
clear images01208_01232

load('images01233_01257.mat');
gamma_WB90_normVS_LeafClosure_09mm=GammaMap(images01007_01032,images01233_01257,3,.03);
clear images01233_01257

load('images01258_01282.mat');
gamma_WB90_normVS_LeafClosure_10mm=GammaMap(images01007_01032,images01258_01282,3,.03);
clear images01258_01282


%compare it against shifting couch SUP by 2mm
%intervals

load('images01283_01307.mat');
gamma_WB90_normVS_CouchShift_SUP_02mm=GammaMap(images01007_01032,images01283_01307,3,.03);
clear images01283_01307

load('images01308_01332.mat');
gamma_WB90_normVS_CouchShift_SUP_04mm=GammaMap(images01007_01032,images01308_01332,3,.03);
clear images01308_01332

load('images01333_01357.mat');
gamma_WB90_normVS_CouchShift_SUP_06mm=GammaMap(images01007_01032,images01333_01357,3,.03);
clear images01333_01357


%compare it against shifting couch GANTRY RIGHT by 2mm
%intervals

load('images01358_01382.mat');
gamma_WB90_normVS_CouchShift_RIGHT_02mm=GammaMap(images01007_01032,images01358_01382,3,.03);
clear images01358_01382

load('images01383_01407.mat');
gamma_WB90_normVS_CouchShift_RIGHT_04mm=GammaMap(images01007_01032,images01383_01407,3,.03);
clear images01383_01407

load('images01408_01432.mat');
gamma_WB90_normVS_CouchShift_RIGHT_06mm=GammaMap(images01007_01032,images01408_01432,3,.03);
clear images01408_01432


%compare it against shifting couch ANT by 2mm
%intervals

load('images01433_01457.mat');
gamma_WB90_normVS_CouchShift_ANT_02mm=GammaMap(images01007_01032,images01433_01457,3,.03);
clear images01433_01457

load('images01458_01482.mat');
gamma_WB90_normVS_CouchShift_ANT_04mm=GammaMap(images01007_01032,images01458_01482,3,.03);
clear images01458_01482

load('images01483_01507.mat');
gamma_WB90_normVS_CouchShift_ANT_06mm=GammaMap(images01007_01032,images01483_01507,3,.03);
clear images01483_01507


clear images01007_01032;


%new normal image
load('images01533_01557.mat');

%compare it against wrong gantry angles
load('images01558_01582.mat');
gamma_WB90_normVS_Gantry_89p8=GammaMap(images01533_01557,images01558_01582,3,.03);
clear images01558_01582

load('images01583_01607.mat');
gamma_WB90_normVS_Gantry_89p6=GammaMap(images01533_01557,images01583_01607,3,.03);
clear images01583_01607

load('images01608_01632.mat');
gamma_WB90_normVS_Gantry_89p4=GammaMap(images01533_01557,images01608_01632,3,.03);
clear images01608_01632


clear images01533_01557;

save('GammaResults20130807');


toc;


