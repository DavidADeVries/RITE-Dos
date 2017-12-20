function [] = Beam_Edit_TprDataPathSelectButtonCallback(app)
%[] = Beam_Edit_TprDataPathSelectButtonCallback(app)

[cancel, filePath] = getFilePath(...
    'Select TPR Data File...',...
    app.settings.treatmentPlanningDefaultPath);

if ~cancel
    energy = app.linacAndEpid.commissionedEnergyBeingEdited;    
    energy = energy.createFromEditGUI(app);
    
    energy.tissuePhantomRatioPath = filePath;
    
    energy.setEditGUI(app);    
    app.linacAndEpid.commissionedEnergyBeingEdited = energy;
end

end

