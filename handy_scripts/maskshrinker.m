function [mask2] = maskshrinker(mask,pixels)
%takes a 2D mask, and makes it smaller in all directions
%   pixels is the amount, in pixels, you want it smaller on all 4 sides

mask2=zeros(size(mask,1),size(mask,2));

for row=1:size(mask,1)
    ones=find(mask(row,:)==1);
    mask2(row,(min(ones)+pixels):(max(ones)-pixels))=1;
end

for col=1:size(mask,2)
    ones=find(mask2(:,col)==1);
    mask2(1:(min(ones)+pixels-1),col)=0;
    mask2((max(ones)-pixels+1):end,col)=0;
end

end

