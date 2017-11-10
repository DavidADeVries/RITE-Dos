function [] = CTSim_LoadButtonCallback(app)
%CTSim_LoadButtonCallback(app)

[cancel, filePath] = getFilePath(...
    'Choose CT Simulator file...',...
    app.settings.ctSimDefaultPath);

if ~cancel
    ctSim = CTSim.loadFromFile(filePath);
    
    app.ctSim = ctSim;
    app.ctSimLoadPath = filePath;
    
    ctSim.setSelectGUI(app);
end

end

