function [] = Settings_TpsDataPathSelectButtonCallback(app)
%[] = Settings_TpsDataPathSelectButtonCallback(app)

[cancel, directoryPath] = getDirectoryPath(...
    'Select TPS Data Path...',...
    app.settings.treatmentPlanningDefaultPath);

if ~cancel
    app.settings.treatmentPlanningDefaultPath = directoryPath;
    
    app.settings.saveToFile();
    
    app.settings.setGUI(app);
end




end

