function [] = Linac_EditButtonCallback(app)
%[] = Linac_EditButtonCallback(app)

if ~isempty(app.linacAndEpid)
    app.linacAndEpid.setEditGUI(app);
end

end

