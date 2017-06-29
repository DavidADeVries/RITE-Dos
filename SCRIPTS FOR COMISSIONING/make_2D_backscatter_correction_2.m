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

% INSTRUCTIONS
% First run RITE Dos to set correct variables and parameters. Then run this
% script TO CORRECT THE RAW EPID IMAGE.




sprintf('Backscatter correction script started')
% re-plot dose from Convolution
%figure; imagesc(epid); colorbar; set(gca, 'CLim', [0.75*(max(max(epid))) 1.05*(max(max(epid)))]); title('DPI from convolution')

% make SUP-INF symmetric PDI using the INF half only
flipped=flipud(epid);
for col=1:512
    symmetric(1:192,col)=flipped(1:192,col);
    symmetric(193:384,col)=epid(193:384,col);
end
%figure; imagesc(symmetric); colorbar; set(gca, 'CLim', [0.75*(max(max(epid))) 1.05*(max(max(epid)))]); title('Symmetric PDI, using INF half')

% You need a mask about 8 pixels smaller on each side
filtermask=fspecial('gaussian',[15 15],5)
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

eval(['cd(''C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\RITE Dos 2015\',UnitStr,'\',ResolutionStr,'\Backscatter_corr\',EnergyStr,' '');']);
eval(['save bsc_l',l_string,'w',w_string,' backscatter_corr;']);
cd(working_dir);
