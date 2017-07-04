function [ FmatInt, fmatInt, TPRmatInt ] = InterpMatrices( Fmatrix, fmatrix, ws, ls, ds, TPRmatrix, TPRdepth, TPRfields)
%UNTITLED2 Interpolates the F, f, and TPR matrices to millimeter resolution.
[Fw, Fl] = meshgrid(ws, ls);
[fl, fd] = meshgrid(ds, ls);
[TPRdepth2, TPRfields2] = meshgrid(TPRdepth,TPRfields);

[Fwq, Flq] = meshgrid(min(ws):0.1:max(ws), min(ls):0.1:max(ls));
[fdq, flq] = meshgrid(min(ds):0.1:max(ds), min(ls):0.1:max(ls));
[TPRdepthq, TPRfieldsq] = meshgrid(min(TPRdepth):0.1:max(TPRdepth),min(TPRfields):0.1:max(TPRfields));

FmatInt = griddata(Fw,Fl,Fmatrix,Fwq,Flq);
fmatInt = griddata(fd, fl, fmatrix, fdq, flq);
TPRmatInt = griddata(TPRdepth2,TPRfields2,TPRmatrix,TPRdepthq,TPRfieldsq);

end

