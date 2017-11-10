function [] = Settings_LinacPathSelectButtonCallback(app)
%[] = Settings_LinacPathSelectButtonCallback(app)

[cancel, directoryPath] = getDirectoryPath(...
    'Select Linear Accelerator Path...',...
    app.settings.linacDefaultPath);

if ~cancel
    app.settings.linacDefaultPath = directoryPath;
    
    app.settings.saveToFile();
    
    app.settings.setGUI(app);
end




end

