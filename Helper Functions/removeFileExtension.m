function filePath = removeFileExtension(filePath)
%filePath = removeFileExtension(filePath)

indices = strfind(filePath, '.');

filePath = filePath(1:indices(end)-1);

end

