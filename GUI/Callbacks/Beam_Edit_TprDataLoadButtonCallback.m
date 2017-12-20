function [] = Beam_Edit_TprDataLoadButtonCallback(app)
%[] = Beam_Edit_TprDataLoadButtonCallback(app)

energy = app.linacAndEpid.commissionedEnergyBeingEdited;

energy = energy.loadTissuePhantomRatioData();

app.linacAndEpid.commissionedEnergyBeingEdited = energy;

app.linacAndEpid.commissionedEnergyBeingEdited.setEditGUI();

end

