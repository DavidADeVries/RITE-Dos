function [] = DoseCalc_EpidPathLoadButtonCallback(app)
%[] = DoseCalc_EpidPathLoadButtonCallback(app)

% load it up
calc = app.patientDoseCalculation;

calc = calc.createFromSelectGUI(app);

% get the path
[cancel, filePath] = getFilePath(...
    'Choose Patient EPID Data Path...',...
    app.settings.patientEpidDataDefaultPath);

% if not cancelled, update GUI and app data
if ~cancel
    calc.epidDataPath = filePath;
    
    calc.setSelectGUI(app);
    
    app.patientDoseCalculation = calc;
end

end

