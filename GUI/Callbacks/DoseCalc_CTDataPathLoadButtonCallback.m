function [] = DoseCalc_CTDataPathLoadButtonCallback(app)
% [] = DoseCalc_CTDataPathLoadButtonCallback(app)

% load it up
calc = app.patientDoseCalculation;

calc = calc.createFromSelectGUI(app);

% get the path
[cancel, filePath] = getFilePath(...
    'Choose Patient CT Data Path...',...
    app.settings.patientCtDataDefaultPath);

% if not cancelled, update GUI and app data
if ~cancel
    calc.ctDataPath = filePath;
    
    calc.setSelectGUI(app);
    
    app.patientDoseCalculation = calc;
end

end

