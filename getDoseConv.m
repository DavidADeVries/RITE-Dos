function [ DoseConv ] = getDoseConv( epid, gsumcr, gsumin, TMRratio, FmatInt, fmatInt )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
epid_max = mean2(epid(189:196,253:260));
epid_min = mean2(epid(1:8,1:8));
% Over 2 or 4? Normally 4, can be 2.
mask = (epid > abs(epid_max+epid_min)/4);
%% Cross Plane
conv_1=zeros(384,512);
for row=1:384;
    
%   GIVE THEM RELATIVE WEIGHTS
    normfactor=trapz(epid(row,:));
    
    profile=epid(row,:)/normfactor;
    conv_1(row,:)=conv(profile,gsumcr,'same');
    
    % Now that I gave correct shape, I must renormalize to the correct height.
    % Do this by finding the midway point along this cross plane profile and
    % renormalize there. But if no points along this row are in the field, then
    % set the whole row to zeros
    
    first=find(mask(row,:), 1 );
    last=find(mask(row,:), 1, 'last' );
    mid=first+round((last-first)/2);
    
    if mid>1
        temp_post_conv=conv_1(row,:);
        temp_pre_conv=epid(row,:);
        conv_1(row,:)=conv_1(row,:)/mean(temp_post_conv(mid-4:mid+4))*mean(temp_pre_conv(mid-4:mid+4));  
    else
        conv_1(row,:)=zeros(1,512);
    end
       
end
%% IN PLANE
conv_2=zeros(384,512);
for col=1:512;
%   GIVE THEM RELATIVE WEIGHTS
    normfactor=trapz(conv_1(:,col));

    
    profile=conv_1(:,col)/normfactor;
    %conv_2(:,col)=conv(profile,gsum,'same');
    conv_2(:,col)=conv(profile,gsumin,'same');

    
    % Now that I gave correct shape, I must renormalize to the correct height.
    % Do this by finding the midway point along this cross plane profile and
    % renormalize there.
    
    first=find(mask(:,col), 1 );
    last=find(mask(:,col), 1, 'last' );
    mid=first+round((last-first)/4);
    
    if mid>1
        temp_post_conv=conv_2(:,col);
        temp_pre_conv=conv_1(:,col);
        conv_2(:,col)=conv_2(:,col)/mean(temp_post_conv(mid-4:mid+4))*mean(temp_pre_conv(mid-4:mid+4));  
    else
        conv_2(:,col)=transpose(zeros(1,384));
    end
    
end

%%        CALCULATE DOSE WITH CONVOLUTION EDGE CORRECTION
DoseConv=mask.*conv_2.*TMRratio.*fmatInt./FmatInt;

end

