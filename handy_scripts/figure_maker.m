%make figures
% 
% %set(0,'DefaultFigureWindowStyle','docked');
% figure; imagesc(epid); title 'raw EPID image (cine, 10fps, 100MU)'; colorbar
% %figure; imagesc(TMRratio); title 'TMR matrix'; colorbar
% %figure; imagesc(FmatrixInverse); title '1/F matrix'; colorbar
% %figure; imagesc(fmatrix); title 'f matrix'; colorbar
% %figure; imagesc(DOSE_calculated); title 'Calculated DOSE (cGy)'; colorbar
% %figure; imagesc(DOSE_calculated_masked); title 'Calculated DOSE, masked (cGy)'; colorbar
% figure; imagesc(eclipse); title 'DOSE from Eclipse (cGy)'; colorbar
% figure; imagesc(DOSE_DIFF); title 'DOSE difference (cGy)'; colorbar; set(gca, 'CLim', [-100, 100]);
% figure; imagesc(DOSE_DIFF_percent_masked); title 'DOSE % difference masked'; colorbar; set(gca, 'CLim', [-10, 10]);




subplot(3,3,1);
imagesc(epid); title 'raw EPID image (cine, 10fps, 100MU)'; colorbar;
%axis equal; axis tight; 
subplot(3,3,2);
imagesc(TMRratio); title 'TMR matrix'; colorbar
%axis equal; axis tight; 
subplot(3,3,3);
imagesc(FmatrixInverse); title '1/F matrix'; colorbar
%axis equal; axis tight; 
subplot(3,3,4);
imagesc(fmatrix); title 'f matrix'; colorbar
%axis equal; axis tight; 
subplot(3,3,5);
imagesc(DOSE_calculated_masked); title 'Calculated DOSE, masked (cGy)'; colorbar
%axis equal; axis tight; 
subplot(3,3,6);
imagesc(DOSE_DIFF_percent_masked); title 'DOSE % difference masked'; colorbar; set(gca, 'CLim', [-15, 15]);
%axis equal; axis tight; 
subplot(3,3,7);
imagesc(eclipse); title 'DOSE from Eclipse (cGy)'; colorbar
%axis equal; axis tight; 
subplot(3,3,8);
imagesc(DOSE_FcorrDerek_masked_w12fs15); title 'Calculated DOSE, edge corrected (cGy)'; colorbar
%axis equal; axis tight; 
subplot(3,3,9);
imagesc(DOSE_FcorrDerek_masked_w12fs15_DIFF); title 'Corrected Dose, % difference'; colorbar; set(gca, 'CLim', [-15 15]);
%axis equal; axis tight; 

%[ax,h3]=suplabel('w=06cm, fs=10x10, CTdata=old(Dal), no correction' ,'t');
%set(h3,'FontSize',15)


