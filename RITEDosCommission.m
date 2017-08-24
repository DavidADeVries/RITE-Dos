function [  ] = RITEDosCommission( )
%% Parameter entry
% Put in the field sizes, widths, displacements used in commissioning and depths and field sizes
% used for TPR
l_s = 5:5:20;
w_s = 5:5:40;
d_s = -10:5:10;
TPRdepth = [0:0.5:20 21:30];
TPRfields = 5:20;

addpath(genpath(pwd));
%% Get dirs
TPSdir = uigetdir(pwd,'Choose Treatment Planning System file');
Fdir = uigetdir(pwd,'Choose directory containing F data');
fdir = uigetdir(pwd,'Choose directory containing f data');
[TPRname, path] = uigetfile();

TPR = load([path TPRname]);
TPR=TPR.temp;
size2 = size(TPR,2);
%To get rid of NaNs
TPR = TPR(~isnan(TPR));
TPR = reshape(TPR,[],size2);

%% Commission
[ECLIPSEs, EPIDsF, EPIDsf] = EPIDgen(TPSdir,Fdir,fdir);

FMATRIX = makeBigF(ECLIPSEs, TPSdir, EPIDsF);
fmat = makeSmallf(fdir,EPIDsf);



[FmatInt,fmatInt,TPRmatInt] = InterpMatrices(FMATRIX, fmat, w_s, l_s, d_s, TPR, TPRdepth, TPRfields);

[ws_in, ws_cr, DoseConvs, HCM] = makeGaussianCorr(ECLIPSEs, EPIDsF, TPRmatInt, FmatInt,fmatInt);

%% Save results
weights = cat(3,ws_in,ws_cr);
save('CommissioningResults.mat','FmatInt','fmatInt','TPRmatInt','weights', 'HCM');



end

