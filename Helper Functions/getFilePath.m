function [cancel, filePath] = getFilePath(title, defaultPath)
%[cancel, filePath] = getFilePath(title, defaultPath)

[filename, path] = uigetfile('*.mat', title, defaultPath);

if filename == 0 % cancelled
    cancel = true;
    filePath = '';
else
    cancel = false;
    filePath = [path, filename];
end

end

