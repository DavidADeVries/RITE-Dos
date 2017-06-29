eclipse=dicomread('4W1B9L1B5W.dcm'); %CHANGE AS NEEDED
eclipse_info=dicominfo('4W1B9L1B5W.dcm'); %CHANGE AS NEEDED

eclipse=double(eclipse);
eclipse=100*eclipse*eclipse_info.DoseGridScaling;

figure; imagesc(eclipse); colorbar;

clear eclipse_info

