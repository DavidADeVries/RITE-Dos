function [] = Linac_CommissionedEnergiesEditButtonCallback(app)
%[] = Linac_CommissionedEnergiesEditButtonCallback(app)

linacAndEpid = app.linacAndEpid;

index = app.Linac_CommissionedEnergiesDropDown.Value;

linacAndEpid.commissionedEnergyBeingEditedIndex = index;
linacAndEpid.commissionedEnergyBeingEdited = linacAndEpid.commissionedEnergies{index};

linacAndEpid.commissionedEnergyBeingEdited.setEditGUI(app);

app.linacAndEpid = linacAndEpid;

end

