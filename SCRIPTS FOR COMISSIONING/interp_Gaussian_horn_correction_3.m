% This script takes all the gaussian horn correction mat files
% (ghc_lxxpxwxxpx.mat) and interpolates the "scaled_horns_corr" 2D maps to steps of field
% size of 1cm rather than 5cm.  

% NOTE: THIS SCRIPT ASSUMES YOU HAVE ONLY VALUES FOR solidwater=(5:5:35)
% I.E. IF YOU WANT RUN IT A SECOND TIME, YOU FIRST NEED TO DELETE PREVIOUS RESULTS

clear all; close all

fieldsizes1=[5 10 15 20]
fieldsizes2=(5:20)
%solidwater=(5:5:35)

files=dir('*.mat')
for i=1:length(files)
load(files(i).name);
MAPS{i}=scaled_horns_corr;
end
MAPS=transpose(MAPS);
MAPS2=reshape(MAPS,7,4);
% so now I want to interpolate across columns

%row 1
x1=MAPS2{1,1};
x2=MAPS2{1,2};
x3=MAPS2{1,3};
x4=MAPS2{1,4};
x = cat(3,x1,x2,x3,x4);
xp = permute(x,[3 1 2]);
yp=interp1(fieldsizes1,xp,fieldsizes2);
y=permute(yp,[2 3 1]);

scaled_horns_corr=y(:,:,2);
save ghc_l06p0w05p0 scaled_horns_corr
scaled_horns_corr=y(:,:,3);
save ghc_l07p0w05p0 scaled_horns_corr
scaled_horns_corr=y(:,:,4);
save ghc_l08p0w05p0 scaled_horns_corr
scaled_horns_corr=y(:,:,5);
save ghc_l09p0w05p0 scaled_horns_corr
scaled_horns_corr=y(:,:,7);
save ghc_l11p0w05p0 scaled_horns_corr
scaled_horns_corr=y(:,:,8);
save ghc_l12p0w05p0 scaled_horns_corr
scaled_horns_corr=y(:,:,9);
save ghc_l13p0w05p0 scaled_horns_corr
scaled_horns_corr=y(:,:,10);
save ghc_l14p0w05p0 scaled_horns_corr
scaled_horns_corr=y(:,:,12);
save ghc_l16p0w05p0 scaled_horns_corr
scaled_horns_corr=y(:,:,13);
save ghc_l17p0w05p0 scaled_horns_corr
scaled_horns_corr=y(:,:,14);
save ghc_l18p0w05p0 scaled_horns_corr
scaled_horns_corr=y(:,:,15);
save ghc_l19p0w05p0 scaled_horns_corr


% row 2
x1=MAPS2{2,1};
x2=MAPS2{2,2};
x3=MAPS2{2,3};
x4=MAPS2{2,4};
x = cat(3,x1,x2,x3,x4);
xp = permute(x,[3 1 2]);
yp=interp1(fieldsizes1,xp,fieldsizes2);
y=permute(yp,[2 3 1]);

scaled_horns_corr=y(:,:,2);
save ghc_l06p0w10p0 scaled_horns_corr
scaled_horns_corr=y(:,:,3);
save ghc_l07p0w10p0 scaled_horns_corr
scaled_horns_corr=y(:,:,4);
save ghc_l08p0w10p0 scaled_horns_corr
scaled_horns_corr=y(:,:,5);
save ghc_l09p0w10p0 scaled_horns_corr
scaled_horns_corr=y(:,:,7);
save ghc_l11p0w10p0 scaled_horns_corr
scaled_horns_corr=y(:,:,8);
save ghc_l12p0w10p0 scaled_horns_corr
scaled_horns_corr=y(:,:,9);
save ghc_l13p0w10p0 scaled_horns_corr
scaled_horns_corr=y(:,:,10);
save ghc_l14p0w10p0 scaled_horns_corr
scaled_horns_corr=y(:,:,12);
save ghc_l16p0w10p0 scaled_horns_corr
scaled_horns_corr=y(:,:,13);
save ghc_l17p0w10p0 scaled_horns_corr
scaled_horns_corr=y(:,:,14);
save ghc_l18p0w10p0 scaled_horns_corr
scaled_horns_corr=y(:,:,15);
save ghc_l19p0w10p0 scaled_horns_corr


% row3
x1=MAPS2{3,1};
x2=MAPS2{3,2};
x3=MAPS2{3,3};
x4=MAPS2{3,4};
x = cat(3,x1,x2,x3,x4);
xp = permute(x,[3 1 2]);
yp=interp1(fieldsizes1,xp,fieldsizes2);
y=permute(yp,[2 3 1]);

scaled_horns_corr=y(:,:,2);
save ghc_l06p0w15p0 scaled_horns_corr
scaled_horns_corr=y(:,:,3);
save ghc_l07p0w15p0 scaled_horns_corr
scaled_horns_corr=y(:,:,4);
save ghc_l08p0w15p0 scaled_horns_corr
scaled_horns_corr=y(:,:,5);
save ghc_l09p0w15p0 scaled_horns_corr
scaled_horns_corr=y(:,:,7);
save ghc_l11p0w15p0 scaled_horns_corr
scaled_horns_corr=y(:,:,8);
save ghc_l12p0w15p0 scaled_horns_corr
scaled_horns_corr=y(:,:,9);
save ghc_l13p0w15p0 scaled_horns_corr
scaled_horns_corr=y(:,:,10);
save ghc_l14p0w15p0 scaled_horns_corr
scaled_horns_corr=y(:,:,12);
save ghc_l16p0w15p0 scaled_horns_corr
scaled_horns_corr=y(:,:,13);
save ghc_l17p0w15p0 scaled_horns_corr
scaled_horns_corr=y(:,:,14);
save ghc_l18p0w15p0 scaled_horns_corr
scaled_horns_corr=y(:,:,15);
save ghc_l19p0w15p0 scaled_horns_corr


% row 4
x1=MAPS2{4,1};
x2=MAPS2{4,2};
x3=MAPS2{4,3};
x4=MAPS2{4,4};
x = cat(3,x1,x2,x3,x4);
xp = permute(x,[3 1 2]);
yp=interp1(fieldsizes1,xp,fieldsizes2);
y=permute(yp,[2 3 1]);

scaled_horns_corr=y(:,:,2);
save ghc_l06p0w20p0 scaled_horns_corr
scaled_horns_corr=y(:,:,3);
save ghc_l07p0w20p0 scaled_horns_corr
scaled_horns_corr=y(:,:,4);
save ghc_l08p0w20p0 scaled_horns_corr
scaled_horns_corr=y(:,:,5);
save ghc_l09p0w20p0 scaled_horns_corr
scaled_horns_corr=y(:,:,7);
save ghc_l11p0w20p0 scaled_horns_corr
scaled_horns_corr=y(:,:,8);
save ghc_l12p0w20p0 scaled_horns_corr
scaled_horns_corr=y(:,:,9);
save ghc_l13p0w20p0 scaled_horns_corr
scaled_horns_corr=y(:,:,10);
save ghc_l14p0w20p0 scaled_horns_corr
scaled_horns_corr=y(:,:,12);
save ghc_l16p0w20p0 scaled_horns_corr
scaled_horns_corr=y(:,:,13);
save ghc_l17p0w20p0 scaled_horns_corr
scaled_horns_corr=y(:,:,14);
save ghc_l18p0w20p0 scaled_horns_corr
scaled_horns_corr=y(:,:,15);
save ghc_l19p0w20p0 scaled_horns_corr

% row 5
x1=MAPS2{5,1};
x2=MAPS2{5,2};
x3=MAPS2{5,3};
x4=MAPS2{5,4};
x = cat(3,x1,x2,x3,x4);
xp = permute(x,[3 1 2]);
yp=interp1(fieldsizes1,xp,fieldsizes2);
y=permute(yp,[2 3 1]);

scaled_horns_corr=y(:,:,2);
save ghc_l06p0w25p0 scaled_horns_corr
scaled_horns_corr=y(:,:,3);
save ghc_l07p0w25p0 scaled_horns_corr
scaled_horns_corr=y(:,:,4);
save ghc_l08p0w25p0 scaled_horns_corr
scaled_horns_corr=y(:,:,5);
save ghc_l09p0w25p0 scaled_horns_corr
scaled_horns_corr=y(:,:,7);
save ghc_l11p0w25p0 scaled_horns_corr
scaled_horns_corr=y(:,:,8);
save ghc_l12p0w25p0 scaled_horns_corr
scaled_horns_corr=y(:,:,9);
save ghc_l13p0w25p0 scaled_horns_corr
scaled_horns_corr=y(:,:,10);
save ghc_l14p0w25p0 scaled_horns_corr
scaled_horns_corr=y(:,:,12);
save ghc_l16p0w25p0 scaled_horns_corr
scaled_horns_corr=y(:,:,13);
save ghc_l17p0w25p0 scaled_horns_corr
scaled_horns_corr=y(:,:,14);
save ghc_l18p0w25p0 scaled_horns_corr
scaled_horns_corr=y(:,:,15);
save ghc_l19p0w25p0 scaled_horns_corr

% row6
x1=MAPS2{6,1};
x2=MAPS2{6,2};
x3=MAPS2{6,3};
x4=MAPS2{6,4};
x = cat(3,x1,x2,x3,x4);
xp = permute(x,[3 1 2]);
yp=interp1(fieldsizes1,xp,fieldsizes2);
y=permute(yp,[2 3 1]);

scaled_horns_corr=y(:,:,2);
save ghc_l06p0w30p0 scaled_horns_corr
scaled_horns_corr=y(:,:,3);
save ghc_l07p0w30p0 scaled_horns_corr
scaled_horns_corr=y(:,:,4);
save ghc_l08p0w30p0 scaled_horns_corr
scaled_horns_corr=y(:,:,5);
save ghc_l09p0w30p0 scaled_horns_corr
scaled_horns_corr=y(:,:,7);
save ghc_l11p0w30p0 scaled_horns_corr
scaled_horns_corr=y(:,:,8);
save ghc_l12p0w30p0 scaled_horns_corr
scaled_horns_corr=y(:,:,9);
save ghc_l13p0w30p0 scaled_horns_corr
scaled_horns_corr=y(:,:,10);
save ghc_l14p0w30p0 scaled_horns_corr
scaled_horns_corr=y(:,:,12);
save ghc_l16p0w30p0 scaled_horns_corr
scaled_horns_corr=y(:,:,13);
save ghc_l17p0w30p0 scaled_horns_corr
scaled_horns_corr=y(:,:,14);
save ghc_l18p0w30p0 scaled_horns_corr
scaled_horns_corr=y(:,:,15);
save ghc_l19p0w30p0 scaled_horns_corr

% row 7
x1=MAPS2{7,1};
x2=MAPS2{7,2};
x3=MAPS2{7,3};
x4=MAPS2{7,4};
x = cat(3,x1,x2,x3,x4);
xp = permute(x,[3 1 2]);
yp=interp1(fieldsizes1,xp,fieldsizes2);
y=permute(yp,[2 3 1]);

scaled_horns_corr=y(:,:,2);
save ghc_l06p0w35p0 scaled_horns_corr
scaled_horns_corr=y(:,:,3);
save ghc_l07p0w35p0 scaled_horns_corr
scaled_horns_corr=y(:,:,4);
save ghc_l08p0w35p0 scaled_horns_corr
scaled_horns_corr=y(:,:,5);
save ghc_l09p0w35p0 scaled_horns_corr
scaled_horns_corr=y(:,:,7);
save ghc_l11p0w35p0 scaled_horns_corr
scaled_horns_corr=y(:,:,8);
save ghc_l12p0w35p0 scaled_horns_corr
scaled_horns_corr=y(:,:,9);
save ghc_l13p0w35p0 scaled_horns_corr
scaled_horns_corr=y(:,:,10);
save ghc_l14p0w35p0 scaled_horns_corr
scaled_horns_corr=y(:,:,12);
save ghc_l16p0w35p0 scaled_horns_corr
scaled_horns_corr=y(:,:,13);
save ghc_l17p0w35p0 scaled_horns_corr
scaled_horns_corr=y(:,:,14);
save ghc_l18p0w35p0 scaled_horns_corr
scaled_horns_corr=y(:,:,15);
save ghc_l19p0w35p0 scaled_horns_corr


