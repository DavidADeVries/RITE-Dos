% EPIDdir = 'Z:\ACADEMIC\Workspaces\Stefano\RITE Dos MATLAB package\Comissioning data\EPID images with centered phantoms (F)\';
EPIDdir = [fdir '\'];
% EPIDfolds = [dir([EPIDdir 'w*'])];
EPIDfolds = [dir([EPIDdir 'l*'])];
EPIDfolds = {EPIDfolds.name};
ep4 = zeros(1,length(EPIDfolds));
eprep = zeros(1,length(EPIDfolds));
for i=1:length(EPIDfolds)
    tic
    x = EPID_prepare_4([EPIDdir EPIDfolds{i}]);
    ep4(i) = toc;
    tic
    y=EPIDprep([EPIDdir EPIDfolds{i}]);
    eprep(i) = toc;
    if ~isequal(x,y)
        disp(['not' EPIDfolds{i}]);
    else
        disp(EPIDfolds{i});
    end
end
plot(1:length(EPIDfolds),ep4,1:length(EPIDfolds),eprep)