set(0,'DefaultFigureWindowStyle','docked');

figure; imagesc(epid); 
colormap('gray')
title ('Raw EPID image (a.u.)','FontSize',13)
axis equal; axis tight; 
colorbar; set(gca, 'CLim', [378000 412000]);set(gca,'FontSize',13)

figure; imagesc(DOSE_masked); 
title ('EPID-calculated dose, uncorrected (cGy)','FontSize',13)
axis equal; axis tight; 
colorbar; set(gca, 'CLim', [0 88]);set(gca,'FontSize',13)

FcorrTemp=Fcorr_w12fs15;
figure; imagesc(FcorrTemp); 
colormap('jet')
title ('Field edge F correction matrix (a.u.)','FontSize',13)
axis equal; axis tight; 
colorbar; set(gca, 'CLim', [0 1.9]);set(gca,'FontSize',13)

DOSE_FcorrDerek_masked_Temp=DOSE_FcorrDerek_masked_w12fs15;
figure; imagesc(DOSE_FcorrDerek_masked_Temp); 
title ('EPID-calculated Dose, corrected (cGy)','FontSize',13)
axis equal; axis tight; 
colorbar; set(gca, 'CLim', [0 88]);set(gca,'FontSize',13)

figure; imagesc(eclipse_masked); 
title ('TPS-predicted dose (cGy)','FontSize',13)
axis equal; axis tight; 
colorbar; set(gca, 'CLim', [0 88]); set(gca,'FontSize',13)

load('gamma_results_SWPw16_samefsFcorr.mat')
figure; imagesc(gamma_w16l15_usingFw12fs15); 
title('Gamma evaluation (3%,3mm)','FontSize',13)
axis equal; axis tight; 
colormap('jet')
colorbar; %set(gca, 'CLim', [0 88]);
set(gca,'FontSize',13)
