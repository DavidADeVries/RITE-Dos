function [] = Settings_CTSimPathSelectButtonCallback(app)
%[] = Settings_CTSimPathSelectButtonCallback(app)

[cancel, directoryPath] = getDirectoryPath(...
    'Select CT Simulator Path...',...
    app.settings.ctSimDefaultPath);

if ~cancel
    app.settings.ctSimDefaultPath = directoryPath;
    
    app.settings.saveToFile();
    
    app.settings.setGUI(app);
end




end

