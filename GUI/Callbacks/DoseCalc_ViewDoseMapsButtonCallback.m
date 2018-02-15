function [] = DoseCalc_ViewDoseMapsButtonCallback(app)
%[] = DoseCalc_ViewDoseMapsButtonCallback(app)

calc = app.patientDoseCalculation;

calc.showDoseMaps();


end

