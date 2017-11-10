function [] = CTSim_EditButtonCallback(app)
%CTSim_EditButtonCallback(app)

if ~isempty(app.ctSim)
    app.ctSim.setEditGUI(app);
end

end

