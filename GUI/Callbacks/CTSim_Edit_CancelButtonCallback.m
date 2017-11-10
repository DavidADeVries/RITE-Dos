function [] = CTSim_Edit_CancelButtonCallback(app)
%[] = CTSim_Edit_CancelButtonCallback(app)

ctSim = app.ctSim;

ctSim.setSelectGUI(app);
app.ctSimCreatingNew = false;


end

