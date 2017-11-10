function [] = Linac_Edit_CancelButtonCallback(app)
%[] = Linac_Edit_CancelButtonCallback(app)

linacAndEpid = app.linacAndEpid;

linacAndEpid.setSelectGUI(app);
app.linacAndEpidCreatingNew = false;


end

