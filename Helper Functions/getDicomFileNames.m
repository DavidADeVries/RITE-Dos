function fileNames = getDicomFileNames(path)
%fileNames = getDicomFileNames(path)

files = dir(makePath(path, ['*', Constants.DICOM_FILE_EXT]));
numFiles = length(files);

fileNames = cell(numFiles,1);

for i=1:1:numFiles
    fileNames{i} = files(i).name;
end


end

