function [ ECLIPSEs, EPIDsF, EPIDsf ] = EPIDgen( TPSdir, Fdir, fdir )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

TPSnames = dir([TPSdir '\w*.dcm']);

ECLIPSEs = zeros(384,512,length(TPSnames));
TPSinfo = dicominfo([TPSdir '\' TPSnames(1).name]);
DoseScale = TPSinfo.DoseGridScaling;
for i=1:length(TPSnames)
    ECLIPSEs(:,:,i) = 100*DoseScale*double(dicomread([TPSdir '\' TPSnames(i).name]));
end
disp('done TPS')
Fnames = dir([Fdir '\w*']);
assignin('base','names',Fnames)
EPIDsF = zeros(384,512,length(Fnames));
for i=1:length(Fnames)
    disp(['F: ' num2str(i)]);
    EPIDsF(:,:,i) = EPIDprep([Fdir '\' Fnames(i).name]);
end

fnames = dir([fdir '\l*']);
fnames = {fnames.name};
fnames = cell2mat(fnames');
fnames = fdirsort(fnames);
EPIDsf = zeros(384,512,length(fnames));
for i=1:length(fnames)
    disp(['f: ' num2str(i)]);
    EPIDsf(:,:,i) = EPIDprep([fdir '\' fnames(i,:)]);
end
end

