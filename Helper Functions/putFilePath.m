function [cancel, filePath] = putFilePath(title, defaultPath)
%[cancel, filePath] = putFilePath(title, defaultPath)

[filename, path] = uiputfile('*.mat', title, defaultPath);

if filename == 0 % cancelled
    cancel = true;
    filePath = '';
else
    cancel = false;
    filePath = [path, filename];
end

end

