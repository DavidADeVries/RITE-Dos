function [] = Linac_NewCommissionButtonCallback(app)
%[] = Linac_NewCommissionButtonCallback(app)

linacAndEpid = LinacAndEPID; % make new LinacAndEPID object

linacAndEpid.setEditGUI(app);
app.linacAndEpidCreatingNew = true;

end

