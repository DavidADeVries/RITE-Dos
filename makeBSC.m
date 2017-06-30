function [ BSCs ] = makeBSC( EPIDs, names )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
BSCs = zeros(size(EPIDs));
for i=1:length(EPIDs)
    flipped = flipud(EPIDs(:,:,i));
    symmetric = zeros(384,512);
    symmetric(1:192,:)=flipped(1:192,:);
    symmetric(193:384,:)=EPIDs(193:384,:,i);
    
    epid_max = mean2(EPIDs(189:196,253:260,i));
    epid_min = mean2(EPIDs(1:8,1:8,i));
    mask = EPIDs(:,:,i) > (abs(epid_max+epid_min)/4);
    
    filtermask = fspecial('gaussian',[15 15],5);
    mask_smaller = floor(imfilter(mask,filtermask));
    
    BSCs(:,:,i) = EPIDs(:,:,i)./symmetric.*mask_smaller;
    BSCs(BSCs(:,:,i)==0,i)=1;
%     
%     name = names(:,:,i);
%     w_string = name(1:3);
%     l_string = name(4:end);
end
end

