function [GAMMAvalue,figGamma] = GammaEval_for2epidimages(REFdcm,MAPdcm,DDtol,DTAtol)
%by Stefano Peca & Brandon Koger, University of Calgary, Canada, 2013.
% ------------------------------------------------------------------------
%This function does a gamma evaluation out of the two 2D input matrices.
%in this version, REF and MAP are both dicom files from the EPID
    REF=dicomread(REFdcm);     REF=double(REF);
    MAP=dicomread(MAPdcm);     MAP=double(MAP);

%DDtol is dose difference tolerance and must be specified in percent, e.g. for 3% type "3". 
%DTAtol is distance to agreement tolerance and must be specified in mm, e.g. for 3mm type "3", 
    %NOTE: dose difference considered is a % of the MAX dose in the reference
    %matrix, i.e. this is a GLOBAL gamma analysis
    DDtol2 = DDtol*max(REF(:))/100;
% ------------------------------------------------------------------------



% ------------------------------------------------------------------------
display ('Please verify the following, as it depends on the imager resolution:');
PhysicalPixelSize=0.7841 %mm/pixels. 267/512 is true for Varian aSi half resolution. You may have to change this.
display ('mm per pixel, projected at iso');
% ------------------------------------------------------------------------

DTAtol2 = DTAtol / PhysicalPixelSize; % This is DTA in number of pixels rather than mm
% where pixelsize is the linear dimansion of 1 pixel projected at at isocenter.
    %NOTE: you can define pixel size either in physical terms (actual size of the
    %pixel) or in terms of its projection at the isocenter plane. We will go with the latter approach.

% ------------------------------------------------------------------------
radius=20; % This determines the square of the circle of points in MAP against which every given point of REF is evaluated.
% So if radius is = max(rows, cols) it's doing it for all points. Most of the
% time a radius of 20 points is enough and it makes the code about 10x faster.
% To make it fast yet acurate, you should use the smallest radius that gives the
% same result as doing it for all points

if size(REF) == size(MAP); % only runs if REF and MAP are same resolution
    rows=size(REF,1);
    cols=size(REF,2);
tic
 GAMMAvalue_sq  = zeros(size(REF));
for i =1:rows; 
    minRow = max(1,i-radius);
    maxRow = min(i+radius,rows);
    xdistSquare = (i - (minRow:maxRow)).^2;
    for j = 1:cols
        minCol = max(1,j-radius);
        maxCol = min(j+radius,cols);
        ydistSquare = (j - (minCol:maxCol)).^2;
        [xGrid,yGrid] = meshgrid(xdistSquare,ydistSquare);
        distMap = (xGrid + yGrid)/DTAtol2^2;
        
        doseDiffMap = ((REF(i,j) - MAP(minRow:maxRow, minCol:maxCol)).^2/DDtol2^2)';
        GAMMAvalue_sq(i,j) = min(min(distMap + doseDiffMap));
    end; 
end
GAMMAvalue=sqrt(GAMMAvalue_sq);

else
display ('Matrix size does not agree');
end;
toc

% Plot result with a nice colormap
figGamma=figure('Colormap',...
    [0 0 1;0 0.0322580635547638 0.967741906642914;0 0.0645161271095276 0.935483872890472;0 0.0967741906642914 0.903225779533386;0 0.129032254219055 0.870967745780945;0 0.161290317773819 0.838709652423859;0 0.193548381328583 0.806451618671417;0 0.225806444883347 0.774193525314331;0 0.25806450843811 0.74193549156189;0 0.290322571992874 0.709677398204803;0 0.322580635547638 0.677419364452362;0 0.354838699102402 0.645161271095276;0 0.387096762657166 0.612903237342834;0 0.419354826211929 0.580645143985748;0 0.451612889766693 0.548387110233307;0 0.483870953321457 0.516129016876221;0 0.516129016876221 0.483870953321457;0 0.548387110233307 0.451612889766693;0 0.580645143985748 0.419354826211929;0 0.612903237342834 0.387096762657166;0 0.645161271095276 0.354838699102402;0 0.677419364452362 0.322580635547638;0 0.709677398204803 0.290322571992874;0 0.74193549156189 0.25806450843811;0 0.774193525314331 0.225806444883347;0 0.806451618671417 0.193548381328583;0 0.838709652423859 0.161290317773819;0 0.870967745780945 0.129032254219055;0 0.903225779533386 0.0967741906642914;0 0.935483872890472 0.0645161271095276;0 0.967741906642914 0.0322580635547638;0 1 0;1 0 0;1 0.0322580635547638 0;1 0.0645161271095276 0;1 0.0967741906642914 0;1 0.129032254219055 0;1 0.161290317773819 0;1 0.193548381328583 0;1 0.225806444883347 0;1 0.25806450843811 0;1 0.290322571992874 0;1 0.322580635547638 0;1 0.354838699102402 0;1 0.387096762657166 0;1 0.419354826211929 0;1 0.451612889766693 0;1 0.483870953321457 0;1 0.516129016876221 0;1 0.548387110233307 0;1 0.580645143985748 0;1 0.612903237342834 0;1 0.645161271095276 0;1 0.677419364452362 0;1 0.709677398204803 0;1 0.74193549156189 0;1 0.774193525314331 0;1 0.806451618671417 0;1 0.838709652423859 0;1 0.870967745780945 0;1 0.903225779533386 0;1 0.935483872890472 0;1 0.967741906642914 0;1 1 0]);
imagesc(GAMMAvalue)
colorbar; set(gca, 'CLim', [0 2]); axis equal; axis tight;
str=sprintf('Global Gamma Evaluation: DD=%f percent, DTA=%f mm',DDtol,DTAtol);
title(str)
