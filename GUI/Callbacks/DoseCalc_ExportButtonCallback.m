function [] = DoseCalc_ExportButtonCallback(app)
%[] = DoseCalc_ExportButtonCallback(app)

[cancel, filePath] = getNewFilePath(...
    Contants.CSV_FILE_EXT,...
    'Save Export As...',...
    app.settings.patientDoseCalculationDefaultPath);

if ~cancel
    calc = app.patientDoseCalculation;
    
    calc.exportDoseMaps(filePath);
end

end

