function [] = Linac_Edit_SaveButtonCallback(app)
%[] = Linac_Edit_SaveButtonCallback(app)

linacAndEpid = app.linacAndEpid;

cancel = false;

if app.linacAndEpidCreatingNew
    [cancel, filePath] = putFilePath('Save Linear Accelerator & EPID...', app.settings.linacDefaultPath);
    
    if ~cancel
        app.linacAndEpidLoadPath = filePath;
    end
    
    linacAndEpid = LinacAndEPID();
end

linacAndEpid = linacAndEpid.createFromEditGUI(app);

if ~cancel
    linacAndEpid.saveToFile(app.linacAndEpidLoadPath);
    
    linacAndEpid.setSelectGUI(app);
    
    app.linacAndEpid = linacAndEpid;
    app.linacAndEpidCreatingNew = false;
end


end

