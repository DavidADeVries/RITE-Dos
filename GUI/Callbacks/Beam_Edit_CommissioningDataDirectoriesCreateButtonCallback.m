function [] = Beam_Edit_CommissioningDataDirectoriesCreateButtonCallback(app)
%[] = Beam_Edit_CommissioningDataDirectoriesCreateButtonCallback(app)

energy = app.linacAndEpid.commissionedEnergyBeingEdited;
energy = energy.createFromEditGUI(app);

energy = energy.createCommissioningDataDirectories();

app.linacAndEpid.commissionedEnergyBeingEdited = energy;

app.linacAndEpid.setSelectGUI(app);
app.linacAndEpid.commissionedEnergyBeingEdited.setEditGUI(app);


end

