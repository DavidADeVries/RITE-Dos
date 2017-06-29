
% find an approximate "dip" in the center of the TPS map. make a mask of it

sprintf('Convolution 2D shape correction script started')



eclipse_profile=eclipse(192,:);
[value,index]=findpeaks(eclipse_profile);
radius1=abs(min(index)-size(eclipse_profile,2)/2)
radius2=abs(max(index)-(size(eclipse_profile,2)/2+1))

if max(size(index))==1
    index(2)=index(1)
end

scalar1=eclipse_profile(index(1))/DOSE_CONV(192,index(1))
scalar2=eclipse_profile(index(2))/DOSE_CONV(192,index(2))

eclipse_profile=eclipse(:,256);
[value,index]=findpeaks(eclipse_profile);
radius3=abs(min(index)-size(eclipse_profile,1)/2)
radius4=abs(max(index)-(size(eclipse_profile,1)/2+1))

scalar3=eclipse_profile(index(1))/DOSE_CONV(index(1),256)
scalar4=eclipse_profile(index(2))/DOSE_CONV(index(2),256)

scalar=mean([scalar1 scalar2 scalar3 scalar4])

DOSE_CONV_2=DOSE_CONV*scalar;

% now, 2D corr in
% radius=1.1*max([radius1 radius2 radius3 radius4]) % a little bigger!
radius = (l/2-1)/0.052; % in pixels

imageSizeX = 512;
imageSizeY = 384;
[columnsInImage rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% Next create the circle in the image.
centerX = 256;
centerY = 192;
circlePixels = (rowsInImage - centerY).^2 + (columnsInImage - centerX).^2 <= radius.^2;
% circlePixels is a 2D "logical" array.
% Now, display it.
% figure; image(circlePixels); axis equal; axis tight; colormap([0 0 0; 1 1 1]);

% now, map the ratio of Calc Dose (not corrected for horns) to TPS Dose inside
% this "dip"

horns_corr_temp1=ones(384,512);
horns_corr_temp1(circlePixels)=DOSE_CONV_2(circlePixels)./eclipse(circlePixels);
%horns_corr_temp1(logical(mask))=DOSE_CONV_2(logical(mask))./eclipse(logical(mask)); % forget about the circel and correct in all the mask!

%figure; imagesc(horns_corr_temp1); axis equal; axis tight; colorbar; set(gca,'Clim', [.97 1.03]);

myfilter = fspecial('gaussian',[6 6], 10);
horns_corr=filter2(myfilter,horns_corr_temp1);
horns_corr(1:50,:)=1;horns_corr(:,1:50)=1;horns_corr(330:384,:)=1;horns_corr(:,460:512)=1;
figure; imagesc(horns_corr_temp1); axis equal; axis tight; colorbar; %set(gca,'Clim', [.97 1.03]);

%scaled_horns_corr=horns_corr;
%scaled_horns_corr(scaled_horns_corr==1)=0;
%scaled_horns_corr=scaled_horns_corr/scalar;
%scaled_horns_corr(scaled_horns_corr==0)=1;

scaled_horns_corr=horns_corr/scalar;

% horns_corr=1./horns_corr_temp2;
% horns_corr=horns_corr/mean(mean(horns_corr(190:195,254:259)));
% figure; imagesc(horns_corr); axis equal; axis tight; colorbar; set(gca,'Clim', [.97 1.03]);

eval(['cd(''C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\RITE Dos 2015\',UnitStr,'\',ResolutionStr,'\Gaussian_CAX_corr\',EnergyStr,' '');']);
eval(['save ghc_l',l_string,'w',w_string,' scalar horns_corr scaled_horns_corr;']);
cd(working_dir);
