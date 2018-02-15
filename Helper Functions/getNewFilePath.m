function [cancel, filePath] = getNewFilePath(extensionFilter, title, defaultPath)
%[cancel, filePath] = getNewFilePath(extensionFiltertitle, defaultPath)

[filename, path] = uiputfile(extensionFilter, title, defaultPath);

if filename == 0 % cancelled
    cancel = true;
    filePath = '';
else
    cancel = false;
    filePath = [path, filename];
end

end

