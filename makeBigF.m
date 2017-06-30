function [ FMAT ] = makeBigF( TPSdir, EPIDsF )
%makeBigF Creates the F matrix.
%   Detailed explanation goes here

% Find the DICOM files within the TPS directory.
TPSnames = dir([TPSdir '\w*.dcm']);
TPSnames2 = {TPSnames.name};
TPSnames2 = cell2mat(TPSnames2');

% Determine the w's and l's used in the measurements.
w_s = unique(str2num(TPSnames2(:,2:3))); %#ok<*ST2NM>
l_s = unique(str2num(TPSnames2(:,5:6)));

% Gets the dose maps from the treatment planning system data and takes the
% center mean.
% All of the files will have the same dose grid scaling and so just read
% the first ones.
TPSinfo = dicominfo(TPSnames(1).name);
TPSdose = zeros(1,length(TPSnames));
for i=1:length(TPSnames)
    TPSmap = double(dicomread(TPSnames(i).name))*100*TPSinfo.DoseGridScaling;
    TPSdose(i) = mean2(TPSmap(189:196,253:260));
end
TPSdose = reshape(TPSdose,length(l_s),length(w_s))';

% Find the center mean of the signal.
Svalues = mean(mean(EPIDsF(189:196,253:260,:)));
Svalues = reshape(Svalues,length(l_s),length(w_s))';

% F is then signal over dose.
FMAT = Svalues ./ TPSdose;
end
