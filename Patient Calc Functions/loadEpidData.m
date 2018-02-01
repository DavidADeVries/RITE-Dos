function [ imageSum, nCine, cax, goodimg, badimg, cineEx ] = loadEpidData(path, epidDims, averWindowSideLength)
% This function takes a series of images in a directory and sums them
% together, while also eliminating outliers.

% Getting the DICOM files
cineNames = getDicomFileNames(path);

nCine = length(cineNames);

% ** INTEGRATED IMAGING **
if nCine == 1
    imageSum = importDicom(makePath(path, cineNames{1}));
    
% ** CONTINUOUS IMAGING **
else    
    % Determining the resolution of the images and then finding the central
    % axis mean signal.
    cax = zeros(1, nCine);
    first = importDicom(makePath(path, cineNames{1}));
    
    ims = zeros(epidDims(2), epidDims(1), nCine);
    ims(:,:,1) = first;
    
    [crossPlaneWindow, inPlaneWindow] = getCentralAveragingWindow(epidDims, averWindowSideLength);
    
    cax(1) = mean2(ims(inPlaneWindow, crossPlaneWindow, 1));
    
    %  finding CAX mean.
    for i=2:nCine
        ims(:,:,i)=double(dicomread([path '\' cineNames{i}]));
        
        cax(i) = mean2(ims(inPlaneWindow, crossPlaneWindow, i));
    end
    imageSum = zeros(size(ims(:,:,1)));
    
    % Determining which measurements to keep. Always drop the first two and
    % then pick the rest based on whether they're within 1 standard deviation
    % of the mean.
    if nCine > 3
        goodInd = cax > (mean(cax) - std(cax)) & cax < (mean(cax) + std(cax));
        goodInd = logical([ 0 0 goodInd(3:end)]);
    else
        toDrop = nCine - 1;
        goodInd = logical([zeros(1, toDrop), ones(1, nCine-toDrop)]);
    end
    % Finding the mean of the good images.
    goodimg = ims(:,:,goodInd);
    badimg = find(~goodInd);
    
    imsum = sum(goodimg,3);
    
    goodimg = find(goodInd);
    avg = imsum ./ sum(goodInd);
    
    % Replaces any bad images with the mean of the good images then rescales
    % them and sums.
    for n=1:nCine
        if any(n == badimg)
            imageAxis = avg;
        else
            imageAxis = ims(:,:,n);
        end
        
        % Takes an example image in the middle of the image set.
        if n == round(nCine/2)
            cineEx = imageAxis;
        end
        
        %     if n==1 %has ~= when should probably be ==
        %                 if size(image_asis,2)~=1024
        %                     sprintf('Image is FULL RES (1024x768)');
        %                 elseif size(image_asis,2)~=512
        %                     sprintf('Image is HALF RES (512x384)');
        %                 end
        %     end
        imageRescaled = -(imageAxis-2^14+1);
        imageSum = imageSum + imageRescaled;
    end
end

end

