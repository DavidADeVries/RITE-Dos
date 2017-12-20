function [matInt_F, matInt_f, matInt_Tpr] = InterpMatrices(mat_F, mat_f, w_s, l_s, d_s, mat_Tpr, tprDepths, tprFields, gridSpacing)
% [matInt_F, matInt_f, matInt_Tpr] = InterpMatrices(mat_F, mat_f, w_s, l_s, d_s, mat_Tpr, tprDepths, tprFields, gridSpacing)
%Interpolates the F, f, and TPR matrices to millimeter resolution.

[Fw, Fl] = meshgrid(w_s, l_s);
[fd, fl] = meshgrid(d_s, l_s);
[TPRdepth2, TPRfields2] = meshgrid(tprDepths, tprFields);

[Fwq, Flq] = meshgrid(...
    min(w_s) : gridSpacing : max(w_s),...
    min(l_s) : gridSpacing : max(l_s));

[fdq, flq] = meshgrid(...
    min(d_s) : gridSpacing : max(d_s),...
    min(l_s) : gridSpacing : max(l_s));

[TPRdepthq, TPRfieldsq] = meshgrid(...
    min(tprDepths) : gridSpacing : max(tprDepths),...
    min(tprFields) : gridSpacing : max(tprFields));

% v4 flag is type of interpolation
matInt_F = griddata(Fw, Fl, mat_F', Fwq, Flq, 'v4')';
matInt_f = griddata(fd, fl, mat_f', fdq, flq, 'v4')';
matInt_Tpr = griddata(TPRdepth2, TPRfields2, mat_Tpr', TPRdepthq, TPRfieldsq, 'v4')';

end

