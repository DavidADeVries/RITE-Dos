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
EPIDsF = zeros(384,512,length(Fnames));
for j=1:length(Fnames)
    disp(['F: ' num2str(j)]);
    EPIDsF(:,:,j) = EPIDprep([Fdir '\' Fnames(j).name]);
end

fnames = dir([fdir '\l*']);
fnames = {fnames.name};
fnames = cell2mat(fnames');
fnames = fdirsort(fnames);
EPIDsf = zeros(384,512,length(fnames));
for k=1:length(fnames)
    disp(['f: ' num2str(k)]);
    EPIDsf(:,:,k) = EPIDprep([fdir '\' fnames(k,:)]);
end
end

