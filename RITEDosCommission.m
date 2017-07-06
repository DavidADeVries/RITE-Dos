function [  ] = RITEDosCommission(  )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Get dirs
TPSdir = uigetdir();
Fdir = uigetdir();
fdir = uigetdir();
[TPRname, path] = uigetfile();

TPR = load([path TPRname]);
%To get rid of NaNs
TPR = TPR(~isnan(TPR));

%% Commission
[ECLIPSEs, EPIDsF, EPIDsf] = EPIDgen(TPSdir,Fdir,fdir);

FMATRIX = makeBigF(ECLIPSEs, TPSdir, EPIDsF);
fmat = makeSmallf(fdir,EPIDsf);

% Probably pull these from the files later
l_s = 5:5:20;
w_s = 5:5:40;
d_s = -10:5:10;
TPRdepth = [0:0.5:20 21:30];
TPRfields = 5:20;

[FmatInt,fmatInt,TPRint] = InterpMatrices(FMATRIX, fmat, w_s, l_s, d_s, TPR, TPRdepth, TPRfields);

[ws_in, ws_cr, DoseConvs] = makeGaussianCorr(ECLIPSEs, EPIDsF, TPRint, FmatInt,fmatInt);

%% Save results
saveloc = uigetdir();
Fsave = input('Name for F matrix: ');
fsave = input('Name for f matrix: ');
weights = cat(3,ws_in,ws_cr);
weightsave = input('Name for Gaussian Weights: ');

% Also save the l_s, w_s, and d_s since it's useful in patient calc.



end

