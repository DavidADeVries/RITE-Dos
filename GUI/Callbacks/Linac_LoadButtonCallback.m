function [] = Linac_LoadButtonCallback(app)
%[] = Linac_LoadButtonCallback(app)

[cancel, filePath] = getFilePath(...
    'Choose Linear Accelerator & EPID file...',...
    app.settings.linacDefaultPath);

if ~cancel
    linacAndEpid = LinacAndEPID.loadFromFile(filePath);
    
    app.linacAndEpid = linacAndEpid;
    app.linacAndEpidLoadPath = filePath;
    
    linacAndEpid.setSelectGUI(app);
end

end

