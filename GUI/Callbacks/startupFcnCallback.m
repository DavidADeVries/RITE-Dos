function [] = startupFcnCallback(app)
%[] = startupFcnCallback(app)

app.settings = Settings.loadFromFile();

app.ctSim.setSelectGUI(app);
app.linacAndEpid.setSelectGUI(app);
app.patientDoseCalculation.setSelectGUI(app);

end

