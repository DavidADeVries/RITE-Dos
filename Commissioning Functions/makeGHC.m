function [ scaled_horns_corr ] = makeGHC( DoseConv, eclipse, l )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
eclipse_profile = eclipse(192,:);
[~, index] = findpeaks(eclipse_profile);

radius1=abs(min(index)-size(eclipse_profile,2)/2);
radius2=abs(max(index)-(size(eclipse_profile,2)/2+1));

if max(size(index))==1
    index(2)=index(1);
end
scalar1=eclipse_profile(index(1))/DoseConv(192,index(1));
scalar2=eclipse_profile(index(2))/DoseConv(192,index(2));

eclipse_profile = eclipse(:,256);
[~,index]=findpeaks(eclipse_profile);

if max(size(index))==1
    index(2)=index(1);
end
radius3=abs(min(index)-size(eclipse_profile,1)/2);
radius4=abs(max(index)-(size(eclipse_profile,1)/2+1));

scalar3=eclipse_profile(index(1))/DoseConv(index(1),256);

scalar4=eclipse_profile(index(2))/DoseConv(index(2),256);

scalar=mean([scalar1 scalar2 scalar3 scalar4]);


DoseConv2 = DoseConv*scalar;

% radius = (l/2-1)/0.052;
radius = max([radius1,radius2,radius3,radius4]);


imageSizeX = 512;
imageSizeY = 384;
[columnsInImage, rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% Next create the circle in the image.
centerX = 256;
centerY = 192;
circlePixels = (rowsInImage - centerY).^2 + (columnsInImage - centerX).^2 <= radius.^2;

% circlePixels is a 2D "logical" array.
% Now, display it.
% figure; image(circlePixels); axis equal; axis tight; colormap([0 0 0; 1 1 1]);

% now, map the ratio of Calc Dose (not corrected for horns) to TPS Dose inside
% this "dip"

horns_corr_temp1=ones(384,512);
horns_corr_temp1(circlePixels)=DoseConv2(circlePixels)./eclipse(circlePixels);

myfilter = fspecial('gaussian',[6 6], 10);
horns_corr=filter2(myfilter,horns_corr_temp1);
%Why this?
horns_corr(1:50,:)=1;horns_corr(:,1:50)=1;horns_corr(330:384,:)=1;horns_corr(:,460:512)=1;
% figure; imagesc(horns_corr_temp1); axis equal; axis tight; colorbar; %set(gca,'Clim', [.97 1.03]);

scaled_horns_corr=scalar./horns_corr;
end

