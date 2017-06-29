% to correct for frame loss at the end of beam delivery
close all; clc
clear MU_comm num_im interp delta lost_MU num_images corr_factor_frame_loss

% 0. Temp
MU=100
UnitStr='Unit09'
EnergyStr='06X'
nCINEfiles=10

% 1. DATA

% 21*28 field, 20cm of SW + 0.6 from couch, centered, 600RR

% these are the lowest MUs which made the corresponding number of images
if UnitStr=='Unit09'    
    if EnergyStr=='06X'
        MU_comm=[5 16 48 101 154]'; % f/s=7.5, f/i=8, 2015_05_12
        num_im=[1 2 5 10 15]'; % f/s=7.5, f/i=8, 2015_05_12
    elseif EnergyStr=='15X'
        MU_comm=[5 10 47 103 155]'; % f/s=xxx, f/i=4, 2015_05_12
        num_im=[1 2 9 20 30]'; % f/s=xxx, f/i=4, 2015_05_12
    end
elseif UnitStr=='Unit10'
    if EnergyStr=='06X'
        MU_comm=[]';
        num_im=[]';
    elseif EnergyStr=='15X'
        MU_15X=[]';
        num_im_15X=[]';
    end
end

% 2. ANALYSIS

figure; plot(MU_comm,num_im,'o--'); xlabel('MU'); ylabel('num of images');

interp(:,1)=ceil(interp1(num_im,MU_comm,[1:max(num_im)]'));
interp(:,2)=[1:max(num_im)]'

for n=1:size(interp,1)-1
    delta(n)=interp(n+1,1)-interp(n,1);
end
delta=mean(delta)

lost_MU=MU-max(interp(interp(:,1)<=MU))

num_images=floor(interp1(MU_comm,num_im,MU))

if num_images~=nCINEfiles
    sprintf('WARNING: frame drop correction is likely inaccurate (predicted image count does not agree with actual number of cine images)')
elseif num_images==nCINEfiles
    sprintf('Frame drop correction agrees with number of cine images')
end

corr_factor_frame_loss=1+lost_MU/delta/num_images

clear MU_comm num_im interp delta lost_MU num_images 

