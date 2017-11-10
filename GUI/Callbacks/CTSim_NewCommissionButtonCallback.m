function [] = CTSim_NewCommissionButtonCallback(app)
%CTSim_NewCommissionButtonCallback(app)

ctSim = CTSim; % make new CTSim object

ctSim.setEditGUI(app);
app.ctSimCreatingNew = true;


end

