
subplot(3,1,1);
imagesc(wed_source_to_iso_TRANSP); title 'source-to-isoplane WED'; colorbar; axis equal; axis([0 512 0 384]);
subplot(3,1,2);
imagesc(wed_iso_to_EPID_TRANSP); title 'isoplane-to-EPID WED'; colorbar; axis equal; axis([0 512 0 384]);
subplot(3,1,3);
imagesc(wed_total_TRANSP); title 'total WED (cm)'; colorbar; axis equal; axis([0 512 0 384]);

[ax,h3]=suplabel('w=06cm, fs=10x10, CTdata=old(Dal)' ,'t');
set(h3,'FontSize',10)


