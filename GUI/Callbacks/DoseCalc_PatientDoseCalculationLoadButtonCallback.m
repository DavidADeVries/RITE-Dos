function [] = DoseCalc_PatientDoseCalculationLoadButtonCallback(app)
%[] = DoseCalc_PatientDoseCalculationLoadButtonCallback(app)

% get the path
[cancel, filePath] = getFilePath(...
    'Choose Patient Dose Calculation File...',...
    app.settings.patientEpidDataDefaultPath);

% if not cancelled, update GUI and app data
if ~cancel
    data = load(filePath);
    
    app.patientDoseCalculation = data.(Constants.PATIENT_DOSE_CALCULATION_FIELD_NAME);
    
    app.patientDoseCalculation.setSelectGUI(app);
end


end

