function [] = Beam_Edit_CommissioningCalculateAndSaveButtonCallback(app)
%[] = Beam_Edit_CommissioningCalculateAndSaveButtonCallback(app)

energy = app.linacAndEpid.commissionedEnergyBeingEdited;

energy = commissionEnergy(energy, app.linacAndEpid, app.settings);

app.linacAndEpid.commissionedEnergyBeingEdited = energy;
app.linacAndEpid = app.linacAndEpid.saveEnergyBeingEdited(app.linacAndEpidLoadPath);


end

