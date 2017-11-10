function [] = hideAllTabs(app)
%function [] = hideAllTabs(app)

    tabHandles = {...
        app.CTSimulatorEditTab,...
        app.LinacEditTab,...
        app.EnergyEditTab,...
        app.SettingsTab
        };

    for i=1:length(tabHandles)
        tabHandles{i}.Parent = [];
    end
end
