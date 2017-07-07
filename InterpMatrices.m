function [ FmatInt, fmatInt, TPRmatInt ] = InterpMatrices( Fmatrix, fmatrix, w_s, l_s, d_s, TPRmatrix, TPRdepth, TPRfields)
%UNTITLED2 Interpolates the F, f, and TPR matrices to millimeter resolution.
[Fw, Fl] = meshgrid(w_s, l_s);
[fd, fl] = meshgrid(d_s, l_s);
[TPRdepth2, TPRfields2] = meshgrid(TPRdepth,TPRfields);

[Fwq, Flq] = meshgrid(min(w_s):0.1:max(w_s), min(l_s):0.1:max(l_s));
[fdq, flq] = meshgrid(min(d_s):0.1:max(d_s), min(l_s):0.1:max(l_s));
[TPRdepthq, TPRfieldsq] = meshgrid(min(TPRdepth):0.1:max(TPRdepth),min(TPRfields):0.1:max(TPRfields));

FmatInt = griddata(Fw,Fl,Fmatrix',Fwq,Flq)';
fmatInt = griddata(fd, fl, fmatrix', fdq, flq)';
TPRmatInt = griddata(TPRdepth2,TPRfields2,TPRmatrix',TPRdepthq,TPRfieldsq)';

end

