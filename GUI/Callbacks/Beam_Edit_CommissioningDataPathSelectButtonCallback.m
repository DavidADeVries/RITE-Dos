function [] = Beam_Edit_CommissioningDataPathSelectButtonCallback(app)
%[] = Beam_Edit_CommissioningDataPathSelectButtonCallback(app)

[cancel, filePath] = getDirectoryPath(...
    'Select Commissioning Data Directory...',...
    app.settings.epidDicomDefaultPath);

if ~cancel
    energy = app.linacAndEpid.commissionedEnergyBeingEdited;    
    energy = energy.createFromEditGUI(app);
    
    energy.commissioningDataPath = filePath;
    
    energy.setEditGUI(app);    
    app.linacAndEpid.commissionedEnergyBeingEdited = energy;
end

end

