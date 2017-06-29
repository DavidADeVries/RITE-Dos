% MAKE A 2D MAP THAT MODELS THE DIFFERENTIAL BACKSCATTER RESPONSE OF THE EPID
%
% The FF correction does not fully account for this effect, because the FF is
% taken with a 21x28 FS. The image we process is smaller, so it will have less
% scatter in-field. And the EPID is oversensitive to this lower energy
% scattering. So when the image is normalized by the FF, this over-corrects for
% the backscatter arm. as a result, the signal from the region over the arm 
% (the SUP edge of the imager) is underestimated.
%
% The method used is that proposed by Berry et al. (Med Phys 2010) of the
% "symmetric" portal dose image, or sPDI

% This script also takes all the EPID images taken through the centered
% phantom and "prepares" them, and saves all these "prepared" EPIDS in the
% directory 'Comissioning data\EPID images with centered phantoms (F)'

% INSTRUCTIONS
clear all; close all
addpath(genpath(pwd));
dosave=true;

sprintf('Backscatter correction script started')
% re-plot dose from Convolution
%figure; imagesc(epid); colorbar; set(gca, 'CLim', [0.75*(max(max(epid))) 1.05*(max(max(epid)))]); title('DPI from convolution')

% make SUP-INF symmetric PDI using the INF half only
cd 'Comissioning data\EPID images with centered phantoms (F)'
epids = dir('w*');
names = {epids.name};
EPIDs = cellfun(@(folder) EPID_prepare_4(char(folder)), names, 'UniformOutput', 0);
save('EPIDs_prepared.mat', 'EPIDs') 
% we will use these prepared images again in make_Gaussian so lets save
% them

cd ..\..
cd 'Backscatter correction'
for i=1:length(EPIDs)
  
    epid=EPIDs{i};
    flipped=flipud(epid);
    symmetric = zeros(384,512);
    for col=1:512
        symmetric(1:192,col)=flipped(1:192,col);
        symmetric(193:384,col)=epid(193:384,col);
    end
    %figure; imagesc(symmetric); colorbar; set(gca, 'CLim', [0.75*(max(max(epid))) 1.05*(max(max(epid)))]); title('Symmetric PDI, using INF half')

    % You need a mask about 8 pixels smaller on each side
    
    epid_64_max = mean2(epid(189:196,253:260));
    epid_64_min = mean2(epid(1:8,1:8));
    mask=+(epid>abs(epid_64_max+epid_64_min)/4);
 
    filtermask=fspecial('gaussian',[15 15],5);
    mask_smaller=imfilter(mask, filtermask);
    mask_smaller=floor(mask_smaller);

    % make a matrix which expresses the asymmetry i
    backscatter_corr=epid(:,:)./(symmetric(:,:)).*mask_smaller;
    backscatter_corr(backscatter_corr==0)=1;
    %figure; imagesc(backscatter_corr); colorbar; set(gca, 'clim' ,[0.95 1.05]); title('weighting matrix')
    clear col epid_fl

    % Now smooth it
    % myfilter = fspecial('average',[10 10]);
    % backscatter_corr=filter2(myfilter,backscatter_corr);
    % backscatter_corr(1:50,:)=1;backscatter_corr(:,1:50)=1;backscatter_corr(330:384,:)=1;backscatter_corr(:,460:512)=1;
    name = names{i};
    w_string = name(1:3);
    l_string = name(4:end);
if dosave
    eval(['save bsc_',w_string,l_string,' backscatter_corr;']);
end
%     cd(working_dir);
end
cd ..
