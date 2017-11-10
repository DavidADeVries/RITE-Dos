function [cancel, directoryPath] = getDirectoryPath(title, defaultPath)
%[cancel, filePath] = getDirectoryPath(title, defaultPath)

[path] = uigetdir(defaultPath, title);

if path == 0 % cancelled
    cancel = true;
    directoryPath = '';
else
    cancel = false;
    directoryPath = path;
end

end

