
clear all

start=226
stop=550

for n=start:stop
image=dicomread(strcat('',int2str(n),'.dcm'));
image_info=dicominfo(strcat('',int2str(n),'.dcm'));
image=double(image);

v=([image_info.RTImageLabel]);
eval([v '= image;']);

clear image image_info v 

end

clear n start stop
