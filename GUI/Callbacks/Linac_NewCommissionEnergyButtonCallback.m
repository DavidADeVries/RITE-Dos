function [] = Linac_NewCommissionEnergyButtonCallback(app)
%[] = Linac_NewCommissionEnergyButtonCallback(app)

linacAndEpid = app.linacAndEpid;

linacAndEpid.commissionedEnergyBeingEditedIndex = 0; % for new energy
linacAndEpid.commissionedEnergyBeingEdited = CommissionedEnergy();

linacAndEpid.commissionedEnergyBeingEdited.setEditGUI(app);

app.linacAndEpid = linacAndEpid;


end

