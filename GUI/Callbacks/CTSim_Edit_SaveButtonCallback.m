function [] = CTSim_Edit_SaveButtonCallback(app)
%[] = CTSim_Edit_SaveButtonCallback(app)

ctSim = app.ctSim;

cancel = false;

if app.ctSimCreatingNew
    [cancel, filePath] = putFilePath('Save CT Simulator...', app.settings.ctSimDefaultPath);
    
    if ~cancel
        app.ctSimLoadPath = filePath;
    end
    
    ctSim = CTSim();
end

ctSim = ctSim.createFromEditGUI(app);

if ~cancel
    ctSim.saveToFile(app.ctSimLoadPath);
    
    ctSim.setSelectGUI(app);
    
    app.ctSim = ctSim;
    app.ctSimCreatingNew = false;
end

end

