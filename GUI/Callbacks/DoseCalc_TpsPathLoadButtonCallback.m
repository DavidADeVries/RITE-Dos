function [] = DoseCalc_TpsPathLoadButtonCallback(app)
%[] = DoseCalc_TpsPathLoadButtonCallback(app)(app)

% load it up
calc = app.patientDoseCalculation;

calc = calc.createFromSelectGUI(app);

% get the path
[cancel, filePath] = getFilePath(...
    'Choose TPS Patient Dose Map Path...',...
    app.settings.patientTpsDataDefaultPath);

% if not cancelled, update GUI and app data
if ~cancel
    calc.tpsDataPath = filePath;
    
    calc.setSelectGUI(app);
    
    app.patientDoseCalculation = calc;
end

end

