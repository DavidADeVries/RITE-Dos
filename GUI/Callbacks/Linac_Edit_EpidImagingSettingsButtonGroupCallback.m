function [] = Linac_Edit_EpidImagingSettingsButtonGroupCallback(app)
%[] = Linac_Edit_EpidImagingSettingsButtonGroupCallback(app)

if app.Linac_Edit_EpidImagingSettingsButtonGroup.SelectedObject == app.IntegratedButton
    app.FramesPerSecondEditField.Enable = 'off';
    app.FramesPerImageEditField.Enable = 'off';
else
    app.FramesPerSecondEditField.Enable = 'on';
    app.FramesPerImageEditField.Enable = 'on';
end

end

