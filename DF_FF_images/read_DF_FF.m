%DFs
MDF07644=dicomread('MDF07644.dcm');
figure
imagesc(MDF07644)
axis equal
axis tight
title('Dark Field image, Aug 18 2014, U9, cine, avg of 30 frames')
figure;
plot(MDF07644(192,:)); xlim([0 512])
title('DF cross-plane profile')
figure;
plot(MDF07644(:,256)); xlim([0 512])
title('DF in-plane profile')


%FFs
MFF07634=dicomread('MFF07634.dcm');
figure
imagesc(MFF07634)
axis equal
axis tight
title('Flood Field image, Aug 18 2014, U9, cine, avg of 30 frames')
figure;
plot(MFF07634(192,:),'.-'); xlim([0 512])
title('FF cross-plane profile')
figure;
plot(MFF07634(:,256),'.-'); xlim([0 512])
title('FF in-plane profile')

MFF07640=dicomread('MFF07640.dcm');
figure
imagesc(MFF07640)
axis equal
axis tight
title('Flood Field image, Aug 18 2014, U9, cine, avg of 30 frames')
figure;
plot(MFF07640(192,:),'.-'); xlim([0 512])
title('FF cross-plane profile')
figure;
plot(MFF07640(:,256),'.-'); xlim([0 512])
title('FF in-plane profile')

MFF07643=dicomread('MFF07643.dcm');
figure
imagesc(MFF07643)
axis equal
axis tight
title('Flood Field image, Aug 18 2014, U9, cine, avg of 30 frames')
figure;
plot(MFF07643(192,:),'.-'); xlim([0 512])
title('FF cross-plane profile')
figure;
plot(MFF07643(:,256),'.-'); xlim([0 512])
title('FF in-plane profile')

MFF07645=dicomread('MFF07645.dcm');
figure
imagesc(MFF07645)
axis equal
axis tight
title('Flood Field image, Aug 18 2014, U9, cine, avg of 30 frames')
figure;
plot(MFF07645(192,:),'.-'); xlim([0 512])
title('FF cross-plane profile')
figure;
plot(MFF07645(:,256),'.-'); xlim([0 512])
title('FF in-plane profile')



%test image
SID07635=dicomread('SID07635.dcm');
figure
imagesc(SID07635)
axis equal; axis tight
title('Test image, Aug 18 2014, U9, cine, avg of 8 frames')
figure;
plot(SID07635(192,:))
title('Test image cross-plane profile'); xlim([0 512])
figure;
plot(SID07635(:,256),'.-'); xlim([0 512])
title('Test image in-plane profile')
