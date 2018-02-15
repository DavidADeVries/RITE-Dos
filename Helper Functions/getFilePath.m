function [cancel, filePath] = getFilePath(title, defaultPath, varargin)
%[cancel, filePath] = getFilePath(title, defaultPath, varargin)

if isempty(varargin)
    fileExt = '*.mat';
else
    fileExt = varargin{1};
end

[filename, path] = uigetfile(fileExt, title, defaultPath);

if filename == 0 % cancelled
    cancel = true;
    filePath = '';
else
    cancel = false;
    filePath = [path, filename];
end

end

