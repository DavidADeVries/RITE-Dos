function [] = Settings_EpidDicomPathSelectButtonCallback(app)
%[] = Settings_EpidDicomPathSelectButtonCallback(app)

[cancel, directoryPath] = getDirectoryPath(...
    'Select EPID Dicom Path...',...
    app.settings.epidDicomDefaultPath);

if ~cancel
    app.settings.epidDicomDefaultPath = directoryPath;
    
    app.settings.saveToFile();
    
    app.settings.setGUI(app);
end




end

