function [] = displayTab(tabHandle, app)
%[] = displayTab(tabHandle, app)

hideAllTabs(app);

tabHandle.Parent = app.TabGroup;

end
