function [] = DoseCalc_CalculateButtonCallback(app)
%[] = DoseCalc_CalculateButtonCallback(app)

%load up
patientDoseCalculation = app.patientDoseCalculation;
patientDoseCalculation = patientDoseCalculation.loadFromSelectGUI(app);

ctSim = app.ctSim;
linacAndEpid = app.linacAndEpid;

%run calculation
patientDoseCalculation = patientDoseCalculation.calculatePatientDose(ctSim, linacAndEpid);

end

