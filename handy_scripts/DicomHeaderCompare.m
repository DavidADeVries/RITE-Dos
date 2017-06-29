function [differences]=DicomHeaderCompare(dcm1, dcm2)

hdr1=dicominfo(dcm1);
hdr2=dicominfo(dcm2);
names1 = fieldnames(hdr1);
names2 = fieldnames(hdr2);
if isequal(names1,names2)==1
names=names1;
    for i = 1 : length(names)
        
        if isequal(hdr1.(names{i}),hdr2.(names{i}))~=1;
            differences(i,1)=names(i);
            differences(i,2)={hdr1.(names{i})};
            differences(i,3)={hdr2.(names{i})};
        end
    end

else
sprintf('Dicom files have different header structure')
end
end