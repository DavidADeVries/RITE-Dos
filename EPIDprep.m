function [ imagesum, nCINE,CAX,goodimg,badimg,CINEex ] = EPIDprep( EPIDdir )
% This function takes a series of images in a directory and sums them
% together, while also eliminating outliers.

% Getting the DICOM files
CINEnames = dir([EPIDdir '\*.dcm']);
CINEnames = {CINEnames.name};

nCINE = length(CINEnames);

% Determining the resolution of the images and then finding the central
% axis mean signal.
CAX=zeros(1,nCINE);
first=double(dicomread(CINEnames{1}));
if ~isequal(size(first),[384,512])
    rsz=true;
    first = imresize(first, [384,512]);
else
    rsz=false;
end
ims = zeros(384,512,nCINE);
ims(:,:,1) = first;
CAX(1) = mean2(ims(189:196,253:260,1));

% Resizing the 384x512 if necessary and finding CAX mean.
for i=2:nCINE
    if rsz
        ims(:,:,i)=imresize(double(dicomread(CINEnames{i})),[384,512]);    
    else
        ims(:,:,i)=double(dicomread(CINEnames{i}));
    end
    CAX(i) = mean2(ims(189:196,253:260,i));
end
imagesum = zeros(size(ims(:,:,1)));

% Determining which measurements to keep. Always drop the first two and
% then pick the rest based on whether they're within 1 standard deviation
% of the mean.
if nCINE > 3
    goodind=CAX>(mean(CAX)-std(CAX))& CAX<(mean(CAX)+std(CAX));
    goodind = logical([ 0 0 goodind(3:end)]);
else
    toDrop = nCINE-1;
    goodind = logical([zeros(1,toDrop),ones(1,nCINE-toDrop)]);
end
% Finding the mean of the good images.
goodimg = ims(:,:,goodind);
badimg = find(~goodind);

imsum = sum(goodimg,3);

goodimg = find(goodind);
avg = imsum/sum(goodind);

% Replaces any bad images with the mean of the good images then rescales
% them and sums.
for n=1:nCINE
    if any(n==badimg)
        image_asis = avg;
    else
        image_asis = ims(:,:,n);
    end
    % Takes an example image in the middle of the image set.
    if n==round(nCINE/2)
        CINEex = image_asis;
    end
    
%     if n==1 %has ~= when should probably be ==
%                 if size(image_asis,2)~=1024
%                     sprintf('Image is FULL RES (1024x768)');
%                 elseif size(image_asis,2)~=512
%                     sprintf('Image is HALF RES (512x384)');
%                 end
%     end
    image_rescaled =-(image_asis-2^14+1);
    imagesum = imagesum + image_rescaled;
end
end

