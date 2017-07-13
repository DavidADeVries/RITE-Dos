function [  ] = RITEDosCommission( TPSdir, Fdir,fdir, ECLIPSEs, EPIDsF,EPIDsf )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Get dirs
% disp('TPS')
% TPSdir = uigetdir();
% disp('Fdir')
% Fdir = uigetdir();
% disp('fdir')
% fdir = uigetdir();
[TPRname, path] = uigetfile();

TPR = load([path TPRname]);
TPR=TPR.temp;
size2 = size(TPR,2);
%To get rid of NaNs
TPR = TPR(~isnan(TPR));
TPR = reshape(TPR,[],size2);

%% Commission
% [ECLIPSEs, EPIDsF, EPIDsf] = EPIDgen(TPSdir,Fdir,fdir);

FMATRIX = makeBigF(ECLIPSEs, TPSdir, EPIDsF);
fmat = makeSmallf(fdir,EPIDsf);

% Probably pull these from the files later
l_s = 5:5:20;
w_s = 5:5:40;
d_s = -10:5:10;
TPRdepth = [0:0.5:20 21:30];
TPRfields = 5:20;

[FmatInt,fmatInt,TPRmatInt] = InterpMatrices(FMATRIX, fmat, w_s, l_s, d_s, TPR, TPRdepth, TPRfields);

[ws_in, ws_cr, DoseConvs, HCM] = makeGaussianCorr(ECLIPSEs, EPIDsF, TPRmatInt, FmatInt,fmatInt);

%% Save results
% saveloc = uigetdir();
% Fsave = input('Name for F matrix: ');
% fsave = input('Name for f matrix: ');
weights = cat(3,ws_in,ws_cr);
% weightsave = input('Name for Gaussian Weights: ');
% fmatInt(101,:)=1;

save('CommissioningFullOpt.mat','FmatInt','fmatInt','TPRmatInt','weights', 'HCM');
% Also save the l_s, w_s, and d_s since it's useful in patient calc.



end

