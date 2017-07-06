function [  ] = RITEDosPatientCalc( PatientEPIDdir )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% Prepare Patient EPIDs
EPID = EPIDprep(PatientEPIDdir);

%% Load commissioning data
% Will include the F, f, and TPR arrays
% and the w_s, l_s, d_s, and depths the data was taken at.
% Gaussian weights


g1 = gauss_distribution(1:1000,500,1.7/.523);
g2 = gauss_distribution(1:1000,500,1.7*2/.523);
g3 = gauss_distribution(1:1000,500,1.7*10/.523);
g4 = gauss_distribution(1:1000,500,1.7*30/.523);

%% Get patient w, l, and d map from CT (DAVID)

%% Construct F, f, and TPR maps from w, l, and d
Fwindex = round((w_map-ones(384,512)*(Fw_s(1)))/0.1)+1;
Flindex = round((l-Fl_s(1))/0.1)+1;

F_map = FmatInt(Fwindex,Flindex);
F_map = reshape(F_map,384,512);

fdindex = round((d_map-ones(384,512)*(fd_s(1)))/0.1)+1;
flindex = round((l-fl_s(1))/0.1)+1;

f_map = fmatInt(fdindex,flindex);
f_map = reshape(f_map,384,512);

TPRlindex = round((l-TPRfields(1))/0.1)+1;
TPRwindex = round((w_map./2-TPRdepth(1))/0.1)+1;
TPRwdindex = round((w_map./2-d_map-TPRdepth(1))/0.1)+1;

TPR1 = TPRmatInt(TPRwdindex,TPRlindex);
TPR1 = reshape(TPR1, 384, 512);
TPR2 = TPRmatInt(TPRwindex,TPRlindex);
TPR2 = reshape(TPR2, 384, 512);

TPRR_map = TPR1./TPR2;

% Get the weights, they are functions of w and l (?) so figure out how we
% get one w since there shouldn't be a map of weights.

gsumcr=(w_cr(1)*g1+w_cr(2)*g2+w_cr(3)*g3+w_cr(4)*g4)/trapz(w_cr(1)*g1+w_cr(2)*g2+w_cr(3)*g3+w_cr(4)*g4);
gsumin=(w_in(1)*g1+w_in(2)*g2+w_in(3)*g3+w_in(4)*g4)/trapz(w_in(1)*g1+w_in(2)*g2+w_in(3)*g3+w_in(4)*g4);

%% Create Patient Dose map using convolution.

PatDoseConv = getDoseConv(EPID,gsumcr,gsumin,TPRR_map,F_map,f_map);
end

