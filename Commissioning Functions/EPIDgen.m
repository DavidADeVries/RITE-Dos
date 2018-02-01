function [tpsValues, epidData_F, epidData_f] = EPIDgen(tpsPath, bigFPath, smallFPath, epidDims, w_s, l_s, d_s, w_forShifts, settings)
%[tpsValues, epidData_F, epidData_f] = EPIDgen(tpsPath, bigFPath, smallFPath, epidDims, w_s, l_s, d_s, w_forShifts, settings)

% ** TPS VALUES READ-IN **

wLen = length(w_s);
lLen = length(l_s);

numEclipseValues = wLen * lLen;

tpsValues = zeros(epidDims(2), epidDims(1), numEclipseValues);

d = 0;

for l_i=1:1:lLen
    l = l_s(l_i);
    
    for w_i=1:1:wLen
        w = w_s(w_i);
        
        path = makePath(tpsPath, makeDataFolderName(l,w,d));
        
        fileNames = getDicomFileNames(path);
        
        if length(fileNames) ~= 1
            error(['No/multiple DICOM file(s) found at: ', path]);
        else
            dicomValue = double(dicomread(makePath(path, fileNames{1})));
            dicomInfo = dicominfo(makePath(path, fileNames{1}));
            doseScale = dicomInfo.(settings.doseGridScalingFieldName);
            
            tpsValues(:,:,((w_i-1)*wLen)+l_i) = Constants.cGy_to_Gy*doseScale*dicomValue;
        end
    end
end

% ** BIG F READ-IN **

Fnames = dir([bigFPath '\w*']);

numEpidValues = wLen * lLen;

epidData_F = zeros(epidDims(2), epidDims(1), numEpidValues);

for i=1:length(Fnames)
    epidData_F(:,:,i) = loadEpidData([bigFPath '\' Fnames(i).name], epidDims, settings.centralAveragingWindowSideLength);
end

d = 0;

for l_i=1:1:lLen
    l = l_s(l_i);
    
    for w_i=1:1:wLen
        w = w_s(w_i);
        
        path = makePath(bigFPath, makeDataFolderName(l,w,d));
        
        fileNames = getDicomFileNames(path);
        
        if isempty(fileNames)
            error(['No DICOM files found at: ', path]);
        else
            tpsValues(:,:,((w_i-1)*lLen)+l_i) = loadEpidData(path, epidDims, settings.centralAveragingWindowSideLength);
        end
    end
end

% ** SMALL f READ-IN **

w = w_forShifts;

dLen = length(d_s);

numEpidValues = lLen * dLen;

epidData_f = zeros(epidDims(2), epidDims(1), numEpidValues);

for l_i=1:lLen
    l = l_s(l_i);
    
    for d_i=1:dLen
        d = d_s(d_i);
        
        path = makePath(smallFPath, makeDataFolderName(l,w,d));
        
        fileNames = getDicomFileNames(path);
        
        if isempty(fileNames)
            error(['No DICOM files found at: ', path]);
        else
            tpsValues(:,:,((w_i-1)*wLen)+l_i) = loadEpidData(path, epidDims, settings.centralAveragingWindowSideLength);
        end
        
        epidData_f(:,:,((l_i-1)*dLen)+d_i) = loadEpidData(path, epidDims, settings.centralAveragingWindowSideLength);
    end
end

end

